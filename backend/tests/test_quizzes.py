"""Real HTTP/SQL quiz flow, with SQLite and a fake Gemini provider only."""
import json
import os
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jwt
from sqlalchemy import BigInteger, create_engine
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.orm import Session
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.setdefault("DATABASE_URL", "sqlite://")
from app.api.deps import get_current_user
from app.core.database import get_db
from app.api.v1.quizzes import router
from app.models.courses_model import Lesson
from app.models.ai_pipeline_model import LessonTranscript
from app.models.quizzes_model import Quiz, QuizQuestion, QuizOption, QuizAttempt, QuizAttemptAnswer
from app.models.system_model import LearningActivity
from app.services import chatbot_service as chat
from app.services.chat_model_routing import ModelCooldowns


@compiles(BigInteger, "sqlite")
def sqlite_bigint(_type, _compiler, **_kwargs):
    return "INTEGER"


@pytest.fixture
def setup(monkeypatch):
    monkeypatch.setenv("JWT_SECRET_KEY", "test-only-secret-not-for-production")
    monkeypatch.setenv("JWT_ALGORITHM", "HS256")
    monkeypatch.setattr(chat, "GEMINI_CHAT_MODELS", ("test-model",))
    monkeypatch.setattr(chat, "model_cooldowns", ModelCooldowns())
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    for model in (Lesson, LessonTranscript, Quiz, QuizQuestion, QuizOption, QuizAttempt, QuizAttemptAnswer, LearningActivity):
        model.__table__.create(engine)
    with Session(engine) as db:
        db.add_all([Lesson(id=1, course_id=10, section_id=1, title="Chuỗi Python"),
                    Lesson(id=2, course_id=10, section_id=1, title="Vòng lặp"),
                    LessonTranscript(lesson_id=1, status="completed", transcript_text="Chuỗi được đặt trong dấu nháy; nối bằng toán tử +.")])
        db.commit()
        app = FastAPI()
        app.include_router(router, prefix="/api/v1")
        holder = {"user": SimpleNamespace(id=7, role="admin")}
        app.dependency_overrides[get_db] = lambda: db
        app.dependency_overrides[get_current_user] = lambda: holder["user"]
        with TestClient(app) as client:
            yield client, db, holder
    engine.dispose()


def draft(title="Quiz chuỗi"):
    return {"title": title, "durationSeconds": 600, "questions": [{
        "question": "Toán tử nào nối hai chuỗi?", "code": '"a" + "b"', "difficulty": "easy",
        "options": [{"label": l, "content": text} for l, text in zip("ABCD", ["+", "-", "/", "%"])],
        "correctLabel": "A", "explanation": "Toán tử + nối hai chuỗi trong Python.",
    }]}


def create(client, publish=True, title="Quiz chuỗi"):
    response = client.post("/api/v1/admin/lessons/1/quiz", json=draft(title))
    assert response.status_code == 201, response.text
    quiz = response.json()["data"]
    if publish:
        assert client.post(f"/api/v1/admin/quizzes/{quiz['id']}/publish").status_code == 200
    return quiz


def test_full_flow_scores_on_server_and_records_activity(setup):
    client, db, holder = setup
    quiz = create(client)
    holder["user"] = SimpleNamespace(id=7, role="student")
    info = client.get("/api/v1/lessons/1/quiz").json()["data"]
    assert info["id"] == quiz["id"]
    assert "questions" not in info
    started = client.post(f"/api/v1/quizzes/{quiz['id']}/start").json()["data"]
    q = started["quiz"]["questions"][0]
    assert "correctLabel" not in q and "explanation" not in q
    assert all("is_correct" not in o for o in q["options"])
    assert client.get("/api/v1/lessons/2/quiz").json()["data"] is None
    payload = {"attemptToken": started["attemptToken"], "answers": [{"questionId": q["id"], "optionId": q["options"][0]["id"]}], "score": 0}
    submitted = client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=payload)
    assert submitted.status_code == 200, submitted.text
    result = submitted.json()["data"]
    assert result["scorePercent"] == 100
    assert result["correctAnswers"] == 1
    assert result["quiz"]["questions"][0]["explanation"]
    assert db.query(QuizAttempt).count() == 1
    assert float(db.query(QuizAttempt).one().score) == 10
    assert db.query(LearningActivity).one().related_lesson_id == 1
    # A network retry returns the saved result rather than a duplicate attempt.
    again = client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=payload).json()["data"]
    assert again["id"] == result["id"]
    assert db.query(QuizAttempt).count() == 1
    assert db.query(LearningActivity).count() == 1
    assert client.get("/api/v1/lessons/1/quiz").json()["data"]["lastAttempt"]["id"] == result["id"]
    holder["user"] = SimpleNamespace(id=99, role="student")
    assert client.get(f"/api/v1/quiz-attempts/{result['id']}").status_code == 404
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=payload).status_code == 400


def test_drafts_hidden_and_admin_routes_protected(setup):
    client, _, holder = setup
    quiz = create(client, publish=False)
    holder["user"] = SimpleNamespace(id=7, role="student")
    assert client.get("/api/v1/lessons/1/quiz").json()["data"] is None
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/start").status_code == 404
    assert client.get(f"/api/v1/admin/quizzes/{quiz['id']}").status_code == 403
    assert client.post("/api/v1/admin/lessons/1/quiz/generate", json={}).status_code == 403
    assert client.put(f"/api/v1/admin/quizzes/{quiz['id']}", json=draft()).status_code == 403


def test_edit_draft_and_published_versions_are_immutable(setup):
    client, _, _ = setup
    quiz = create(client, publish=False)
    changed = draft("Đã duyệt")
    changed["questions"][0]["correctLabel"] = "B"
    assert client.put(f"/api/v1/admin/quizzes/{quiz['id']}", json=changed).status_code == 200
    assert client.post(f"/api/v1/admin/quizzes/{quiz['id']}/publish").status_code == 200
    assert client.put(f"/api/v1/admin/quizzes/{quiz['id']}", json=draft()).status_code == 409
    newer = create(client, title="Quiz mới")
    assert client.get("/api/v1/lessons/1/quiz").json()["data"]["id"] == newer["id"]
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/start").status_code == 200


def test_reject_foreign_options_duplicate_questions_and_expired_tokens(setup):
    client, db, _ = setup
    quiz = create(client)
    other = create(client)
    started = client.post(f"/api/v1/quizzes/{quiz['id']}/start").json()["data"]
    question = started["quiz"]["questions"][0]
    wrong_option = other["questions"][0]["options"][0]["id"]
    base = {"attemptToken": started["attemptToken"], "answers": [{"questionId": question["id"], "optionId": wrong_option}]}
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=base).status_code == 422
    base["answers"] = [{"questionId": question["id"], "optionId": None}] * 2
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=base).status_code == 422
    base["answers"] = [{"questionId": other["questions"][0]["id"], "optionId": wrong_option}]
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=base).status_code == 422
    claims = jwt.decode(started["attemptToken"], os.environ["JWT_SECRET_KEY"], algorithms=["HS256"])
    claims["exp"] = 0
    base["attemptToken"] = jwt.encode(claims, os.environ["JWT_SECRET_KEY"], algorithm="HS256")
    assert client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json=base).status_code == 400
    assert db.query(QuizAttempt).count() == 0


def test_unanswered_questions_score_zero(setup):
    client, _, _ = setup
    quiz = create(client)
    started = client.post(f"/api/v1/quizzes/{quiz['id']}/start").json()["data"]
    response = client.post(f"/api/v1/quizzes/{quiz['id']}/submit", json={"attemptToken": started["attemptToken"], "answers": []})
    assert response.json()["data"]["scorePercent"] == 0


def test_invalid_questions_never_saved(setup):
    client, db, _ = setup
    payload = draft()
    payload["questions"][0]["options"][1]["label"] = "A"
    assert client.post("/api/v1/admin/lessons/1/quiz", json=payload).status_code == 422
    payload = draft()
    payload["questions"][0]["options"][1]["content"] = "+"
    assert client.post("/api/v1/admin/lessons/1/quiz", json=payload).status_code == 422
    assert db.query(Quiz).count() == 0


def test_ai_generation_uses_transcript_and_only_creates_draft(setup, monkeypatch):
    client, db, _ = setup
    prompts = []
    class FakeModel:
        def __init__(self, _name): pass
        async def generate_content_async(self, prompt, **kwargs):
            prompts.append(prompt)
            return SimpleNamespace(text=json.dumps(draft(), ensure_ascii=False))
    monkeypatch.setattr(chat.genai, "GenerativeModel", FakeModel)
    response = client.post("/api/v1/admin/lessons/1/quiz/generate", json={"count": 1})
    assert response.status_code == 201, response.text
    assert response.json()["data"]["status"] == "draft"
    assert "Chuỗi được đặt trong dấu nháy" in prompts[0]
    assert db.query(Quiz).count() == 1
    assert client.get("/api/v1/lessons/1/quiz").json()["data"] is None
    assert client.post("/api/v1/admin/lessons/2/quiz/generate", json={"count": 1}).status_code == 409
    assert len(prompts) == 1


def test_invalid_ai_json_does_not_persist_partial_quiz(setup, monkeypatch):
    client, db, _ = setup
    class BadModel:
        def __init__(self, _name): pass
        async def generate_content_async(self, *_args, **_kwargs): return SimpleNamespace(text='{"questions": []}')
    monkeypatch.setattr(chat.genai, "GenerativeModel", BadModel)
    assert client.post("/api/v1/admin/lessons/1/quiz/generate", json={"count": 1}).status_code == 502
    assert db.query(Quiz).count() == 0


def test_generation_falls_back_on_quota_without_creating_duplicate_quizzes(setup, monkeypatch):
    from google.api_core.exceptions import ResourceExhausted
    client, db, _ = setup
    calls = []
    monkeypatch.setattr(chat, "GEMINI_CHAT_MODELS", ("primary", "backup"))
    class Model:
        def __init__(self, name): self.name = name
        async def generate_content_async(self, *_args, **_kwargs):
            calls.append(self.name)
            if self.name == "primary": raise ResourceExhausted("Quota")
            return SimpleNamespace(text=json.dumps(draft()))
    monkeypatch.setattr(chat.genai, "GenerativeModel", Model)
    assert client.post("/api/v1/admin/lessons/1/quiz/generate", json={"count": 1}).status_code == 201
    assert calls == ["primary", "backup"]
    assert db.query(Quiz).count() == 1


def test_invalid_existing_quiz_cannot_be_published_or_started(setup):
    client, db, _ = setup
    quiz = create(client, publish=False)
    row = db.get(Quiz, quiz["id"])
    for option in row.questions[0].options: option.is_correct = False
    db.commit()
    assert client.post(f"/api/v1/admin/quizzes/{row.id}/publish").status_code == 422
    row.status = "published"
    db.commit()
    assert client.post(f"/api/v1/quizzes/{row.id}/start").status_code == 409


def test_unauthenticated_requests_rejected(setup):
    client, _, _ = setup
    client.app.dependency_overrides.pop(get_current_user)
    assert client.get("/api/v1/lessons/1/quiz").status_code == 401
    assert client.post("/api/v1/admin/lessons/1/quiz/generate", json={}).status_code == 401


def test_database_integrity_failure_is_not_reported_as_ai_failure(setup, monkeypatch, caplog):
    from sqlalchemy.exc import IntegrityError
    client, db, _ = setup
    def fail_commit():
        raise IntegrityError("insert", {}, RuntimeError("constraint"))
    monkeypatch.setattr(db, "commit", fail_commit)
    response = client.post("/api/v1/admin/lessons/1/quiz", json=draft())
    assert response.status_code == 500
    assert "database" in response.json()["detail"]
    assert "Quiz save failed" in caplog.text
    assert db.query(Quiz).count() == 0
