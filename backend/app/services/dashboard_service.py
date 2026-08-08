from sqlalchemy import func
from sqlalchemy.orm import Session, selectinload

from app.models.ai_pipeline_model import AIChatMessage, ChatSender
from app.models.courses_model import Course, LessonVideo
from app.models.system_model import ActivityType, LearningActivity
from app.models.users_model import User, UserRole

ACTIVITY_STATUS_LABEL = {
    ActivityType.video: "ĐÃ XEM",
    ActivityType.quiz: "HOÀN THÀNH",
    ActivityType.ai: "ĐÃ HỎI",
    ActivityType.account: "CẬP NHẬT",
    ActivityType.certificate: "NHẬN CHỨNG CHỈ",
    ActivityType.course: "ĐĂNG KÝ",
}


class DashboardService:
    @staticmethod
    def get_stats(db: Session) -> dict:
        total_students = db.query(User).filter(User.role == UserRole.student).count()
        total_courses = db.query(Course).count()
        ai_videos_processed = (
            db.query(LessonVideo).filter(LessonVideo.processing_status == "completed").count()
        )
        ai_questions_count = (
            db.query(AIChatMessage).filter(AIChatMessage.sender == ChatSender.user).count()
        )

        return {
            "totalStudents": total_students,
            "totalCourses": total_courses,
            "aiVideosProcessed": ai_videos_processed,
            "aiQuestionsCount": ai_questions_count,
        }

    @staticmethod
    def get_ai_processing_breakdown(db: Session) -> dict:
        rows = (
            db.query(LessonVideo.processing_status, func.count(LessonVideo.id))
            .group_by(LessonVideo.processing_status)
            .all()
        )

        breakdown = {"pending": 0, "processing": 0, "completed": 0, "failed": 0}
        for status_value, count in rows:
            key = getattr(status_value, "value", status_value)
            if key in breakdown:
                breakdown[key] = count

        return breakdown

    @staticmethod
    def get_recent_activity(db: Session, limit: int = 10) -> list:
        activities = (
            db.query(LearningActivity)
            .options(selectinload(LearningActivity.user))
            .order_by(LearningActivity.created_at.desc())
            .limit(limit)
            .all()
        )
        return [DashboardService._serialize_activity(activity) for activity in activities]

    @staticmethod
    def _serialize_activity(activity: LearningActivity) -> dict:
        subject_type = "video" if activity.activity_type == ActivityType.video else "user"
        subject_name = "Người dùng"
        if activity.user:
            subject_name = activity.user.full_name or activity.user.username

        return {
            "id": int(activity.id),
            "time": activity.created_at.isoformat() if activity.created_at else "",
            "subject": subject_name,
            "subjectType": subject_type,
            "action": activity.title,
            "status": ACTIVITY_STATUS_LABEL.get(activity.activity_type, "HOẠT ĐỘNG"),
        }

    @staticmethod
    def get_dashboard_data(db: Session) -> dict:
        return {
            "stats": DashboardService.get_stats(db),
            "recentActivity": DashboardService.get_recent_activity(db),
            "aiProcessing": DashboardService.get_ai_processing_breakdown(db),
        }