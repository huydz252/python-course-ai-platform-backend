"""Chat context regression tests using an isolated SQLite DB and a fake AI model."""
import asyncio
import os
import sys
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import pytest
from fastapi import HTTPException
from sqlalchemy import BigInteger, create_engine
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.orm import Session

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
# Importing the app must not require connecting to the configured production DB.
os.environ.setdefault("DATABASE_URL", "sqlite://")

from app.models import AIChatMessage, AIChatSession
from app.models.ai_pipeline_model import LessonTranscript
from app.models.courses_model import Lesson
from app.schemas.chatbot import ChatRequest
from app.services.chatbot_service import ChatbotService
from app.services import chatbot_service
from google.api_core.exceptions import ResourceExhausted, NotFound, PermissionDenied


@pytest.fixture(autouse=True)
def isolate_model_routing(monkeypatch):
    monkeypatch.setattr(chatbot_service, "GEMINI_CHAT_MODELS", ("primary", "backup", "third"))
    from app.services.chat_model_routing import ModelCooldowns
    monkeypatch.setattr(chatbot_service, "model_cooldowns", ModelCooldowns())


@compiles(BigInteger, "sqlite")
def sqlite_bigint(_type, _compiler, **_kwargs):
    return "INTEGER"


@pytest.fixture
def db():
    engine = create_engine("sqlite://")
    for model in (Lesson, LessonTranscript, AIChatSession, AIChatMessage):
        model.__table__.create(engine)
    with Session(engine) as session:
        session.add_all([
            Lesson(id=1, course_id=10, section_id=1, title="Vòng lặp", description="for và while"),
            Lesson(id=2, course_id=10, section_id=1, title="Danh sách"),
            LessonTranscript(id=1, lesson_id=1, transcript_text="Nội dung cũ", status="completed"),
            LessonTranscript(id=2, lesson_id=1, transcript_text="Dùng for để duyệt dãy và while để lặp theo điều kiện.", status="completed"),
            LessonTranscript(id=3, lesson_id=1, transcript_text="Đang tạo", status="processing"),
            LessonTranscript(id=4, lesson_id=2, transcript_text="Nội dung bài khác", status="completed"),
        ])
        session.commit()
        yield session
    engine.dispose()


def ask(db, request, user_id=7, model_type=None):
    prompts = []

    class FakeModel:
        def __init__(self, _name):
            pass

        async def generate_content_async(self, prompt, stream, request_options):
            assert stream is True
            assert request_options["retry"] is None
            prompts.append(prompt)

            async def chunks():
                yield SimpleNamespace(text="Bài học giải thích vòng lặp.")
            return chunks()

    async def run():
        with patch("app.services.chatbot_service.genai.GenerativeModel", model_type or FakeModel):
            session_id, generator = await ChatbotService.get_ai_stream_response(request, user_id, db)
            reply = "".join([part async for part in generator])
            return session_id, reply

    session_id, reply = asyncio.run(run())
    return session_id, reply, prompts


def test_summary_uses_latest_completed_transcript_and_saves_reply(db):
    session_id, reply, prompts = ask(db, ChatRequest(message="Tóm tắt bài học này", lesson_id=1))
    assert "Dùng for để duyệt dãy" in prompts[0]
    assert "Nội dung cũ" not in prompts[0]
    assert "Đang tạo" not in prompts[0]
    assert "Nội dung bài khác" not in prompts[0]
    assert reply == "Bài học giải thích vòng lặp."
    assert db.get(AIChatSession, session_id).course_id == 10
    assert db.query(AIChatMessage).count() == 2


def test_followup_inherits_lesson_and_previous_messages(db):
    session_id, _, _ = ask(db, ChatRequest(message="Tóm tắt", lesson_id=1))
    next_id, _, prompts = ask(db, ChatRequest(message="Cho ví dụ về phần đó", session_id=session_id))
    assert next_id == session_id
    assert "Dùng for để duyệt dãy" in prompts[0]
    assert "<history>" in prompts[0]
    assert "Học viên: Tóm tắt" in prompts[0]
    assert "Trợ lý: Bài học giải thích vòng lặp." in prompts[0]
    assert prompts[0].count("Cho ví dụ về phần đó") == 1


def test_cannot_write_to_another_users_session(db):
    session_id, _, _ = ask(db, ChatRequest(message="Tóm tắt", lesson_id=1))
    with pytest.raises(HTTPException) as exc:
        ask(db, ChatRequest(message="Forged", session_id=session_id), user_id=999)
    assert exc.value.status_code == 403
    assert db.query(AIChatMessage).count() == 2


def test_rejects_switching_lesson_inside_a_session(db):
    session_id, _, _ = ask(db, ChatRequest(message="Tóm tắt", lesson_id=1))
    with pytest.raises(HTTPException) as exc:
        ask(db, ChatRequest(message="Wrong lesson", session_id=session_id, lesson_id=2))
    assert exc.value.status_code == 400


def test_missing_lesson_does_not_create_chat(db):
    with pytest.raises(HTTPException) as exc:
        ask(db, ChatRequest(message="Tóm tắt", lesson_id=999))
    assert exc.value.status_code == 404
    assert db.query(AIChatSession).count() == 0


def test_missing_transcript_is_explicit_and_generic_chat_still_works(db):
    db.query(LessonTranscript).filter(LessonTranscript.lesson_id == 2).delete()
    db.commit()
    _, _, prompts = ask(db, ChatRequest(message="Tóm tắt", lesson_id=2))
    assert "chưa có transcript hoàn tất" in prompts[0]
    _, _, generic = ask(db, ChatRequest(message="Python là gì?"))
    assert "<transcript>" not in generic[0]


def test_rejects_wrong_course_before_creating_session(db):
    with pytest.raises(HTTPException) as exc:
        ask(db, ChatRequest(message="Tóm tắt", lesson_id=1, course_id=99))
    assert exc.value.status_code == 400
    assert db.query(AIChatSession).count() == 0


def test_long_transcript_reports_context_limit():
    prompt = ChatbotService.build_prompt("Tóm tắt", {
        "title": "Long", "description": "", "transcript": "a" * 120_001,
    }, [])
    assert "chỉ có phần đầu" in prompt


def test_success_logs_start_first_chunk_and_completion(db, caplog):
    caplog.set_level("INFO", logger="uvicorn.error")
    ask(db, ChatRequest(message="Tóm tắt", lesson_id=1))
    assert "AI start" in caplog.text
    assert "transcript_chars=" in caplog.text
    assert "AI first_chunk" in caplog.text
    assert "AI complete" in caplog.text
    assert "Dùng for để duyệt dãy" not in caplog.text


def test_connection_timeout_ends_stream_and_logs_stage(db, caplog):
    class SlowModel:
        def __init__(self, _name): pass

        async def generate_content_async(self, *_args, **_kwargs):
            await asyncio.sleep(1)

    with patch("app.services.chatbot_service.AI_FIRST_CHUNK_TIMEOUT", 0.01):
        _, reply, _ = ask(db, ChatRequest(message="Test", lesson_id=1), model_type=SlowModel)
    assert "phản hồi quá lâu" in reply
    assert "AI timeout" in caplog.text
    assert "stage=connecting" in caplog.text
    assert db.query(AIChatMessage).count() == 1


def test_stalled_stream_times_out_after_partial_reply(db, caplog):
    class StalledModel:
        def __init__(self, _name): pass

        async def generate_content_async(self, *_args, **_kwargs):
            async def chunks():
                yield SimpleNamespace(text="Partial")
                await asyncio.sleep(1)
            return chunks()

    with patch("app.services.chatbot_service.AI_IDLE_TIMEOUT", 0.01):
        _, reply, _ = ask(db, ChatRequest(message="Test"), model_type=StalledModel)
    assert reply.startswith("Partial")
    assert "phản hồi quá lâu" in reply
    assert "stage=streaming" in caplog.text
    assert db.query(AIChatMessage).count() == 1


def test_provider_failure_logged_without_exposing_key(db, caplog):
    class BrokenModel:
        def __init__(self, _name): pass

        async def generate_content_async(self, *_args, **_kwargs):
            raise RuntimeError("404 bad model; key=test-secret")

    with patch("app.services.chatbot_service.GEMINI_API_KEY", "test-secret"):
        _, reply, _ = ask(db, ChatRequest(message="Test"), model_type=BrokenModel)
    assert "AI error" in caplog.text
    assert "404 bad model" in caplog.text
    assert "test-secret" not in caplog.text
    assert "test-secret" not in reply


def routing_model(outcomes, calls):
    class Model:
        def __init__(self, name):
            self.name = name
            calls.append(name)

        async def generate_content_async(self, prompt, **kwargs):
            outcome = outcomes.get(self.name, "OK")
            if isinstance(outcome, Exception):
                raise outcome

            async def chunks():
                yield SimpleNamespace(text=outcome)
            return chunks()
    return Model


@pytest.mark.parametrize("error", [ResourceExhausted("Quota exceeded"), NotFound("Model unavailable")])
def test_fallback_uses_same_session_and_records_actual_model(db, error, caplog):
    calls = []
    session_id, reply, _ = ask(db, ChatRequest(message="Tóm tắt", lesson_id=1), model_type=routing_model({"primary": error}, calls))
    assert calls == ["primary", "backup"]
    assert reply == "OK"
    messages = db.query(AIChatMessage).order_by(AIChatMessage.id).all()
    assert len(messages) == 2
    assert messages[-1].model_name == "backup"
    assert messages[-1].session_id == session_id
    assert "AI fallback" in caplog.text

    calls.clear()
    ask(db, ChatRequest(message="Hỏi tiếp", session_id=session_id), model_type=routing_model({}, calls))
    assert calls == ["backup"], "skip the primary model while its cooldown is active"


def test_exhausted_models_stop_after_three_and_report_quota(db):
    calls = []
    model = routing_model({name: ResourceExhausted("Quota") for name in ["primary", "backup", "third"]}, calls)
    _, reply, _ = ask(db, ChatRequest(message="Test"), model_type=model)
    assert calls == ["primary", "backup", "third"]
    assert "hết hạn mức" in reply
    assert db.query(AIChatMessage).count() == 1
    calls.clear()
    ask(db, ChatRequest(message="Test again"), model_type=model)
    assert calls == [], "do not call known exhausted models again immediately"


def test_permission_errors_do_not_trigger_model_switch(db):
    calls = []
    ask(db, ChatRequest(message="Test"), model_type=routing_model({"primary": PermissionDenied("Bad key")}, calls))
    assert calls == ["primary"]


def test_no_fallback_once_partial_reply_has_streamed(db):
    calls = []
    class PartialModel:
        def __init__(self, name): calls.append(name)

        async def generate_content_async(self, *_args, **_kwargs):
            async def chunks():
                yield SimpleNamespace(text="Partial answer")
                raise ResourceExhausted("Quota during streaming")
            return chunks()

    _, reply, _ = ask(db, ChatRequest(message="Test"), model_type=PartialModel)
    assert calls == ["primary"]
    assert reply.startswith("Partial answer")
    assert db.query(AIChatMessage).count() == 1


def test_model_list_trims_and_deduplicates(monkeypatch):
    from app.services.chat_model_routing import configured_models
    monkeypatch.setenv("GEMINI_CHAT_MODELS", " models/first, second,first,, ")
    assert configured_models() == ("first", "second")
    monkeypatch.setenv("GEMINI_CHAT_MODELS", "")
    monkeypatch.setenv("GEMINI_CHAT_MODEL", "single")
    assert configured_models() == ("single",)
