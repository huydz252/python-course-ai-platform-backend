from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.api.deps import get_current_user, require_admin
from app.core.database import get_db
from app.models.quizzes_model import Quiz
from app.models.users_model import User
from app.schemas.quiz import QuizDraftInput, QuizGenerateInput, QuizSubmitInput
from app.services.quiz_service import QuizService
from app.utils.response import success_response

router = APIRouter()


@router.get("/lessons/{lesson_id}/quiz")
def lesson_quiz(lesson_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return success_response(QuizService.for_lesson(db, lesson_id, int(user.id)))


@router.post("/quizzes/{quiz_id}/start")
def start_quiz(quiz_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return success_response(QuizService.start(db, quiz_id, int(user.id)))


@router.post("/quizzes/{quiz_id}/submit")
def submit_quiz(quiz_id: int, payload: QuizSubmitInput, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return success_response(QuizService.submit(db, quiz_id, int(user.id), payload))


@router.get("/quiz-attempts/{attempt_id}")
def quiz_result(attempt_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return success_response(QuizService.result(db, attempt_id, int(user.id)))


@router.get("/admin/quizzes")
def list_quizzes(lesson_id: int = Query(alias="lessonId"), db: Session = Depends(get_db), _: User = Depends(require_admin)):
    rows = db.query(Quiz).filter(Quiz.lesson_id == lesson_id).order_by(Quiz.id.desc()).all()
    return success_response([QuizService.serialize(q, include_questions=False) for q in rows])


@router.get("/admin/quizzes/{quiz_id}")
def admin_quiz(quiz_id: int, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    return success_response(QuizService.serialize(QuizService.get_quiz(db, quiz_id), admin=True))


@router.post("/admin/lessons/{lesson_id}/quiz", status_code=201)
def create_quiz(lesson_id: int, payload: QuizDraftInput, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    return success_response(QuizService.save_draft(db, lesson_id, payload))


@router.post("/admin/lessons/{lesson_id}/quiz/generate", status_code=201)
async def generate_quiz(lesson_id: int, payload: QuizGenerateInput, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    return success_response(await QuizService.generate(db, lesson_id, payload))


@router.put("/admin/quizzes/{quiz_id}")
def update_quiz(quiz_id: int, payload: QuizDraftInput, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    quiz = QuizService.get_quiz(db, quiz_id)
    return success_response(QuizService.save_draft(db, quiz.lesson_id, payload, quiz_id))


@router.post("/admin/quizzes/{quiz_id}/publish")
def publish_quiz(quiz_id: int, db: Session = Depends(get_db), _: User = Depends(require_admin)):
    return success_response(QuizService.publish(db, quiz_id))
