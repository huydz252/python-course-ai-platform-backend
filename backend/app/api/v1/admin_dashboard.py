# backend/app/api/v1/admin_dashboard.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.users_model import User
from app.services.dashboard_service import DashboardService

router = APIRouter()


def success_response(data, message: str = "OK"):
    return {"success": True, "message": message, "data": data}


def get_current_admin_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "success": False,
                "message": "Bạn không có quyền truy cập chức năng quản trị.",
                "errorCode": "FORBIDDEN_ADMIN_ONLY",
                "details": None,
            },
        )
    return current_user


@router.get("", status_code=status.HTTP_200_OK, include_in_schema=False)
def get_dashboard_no_slash(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user),
):
    return success_response(DashboardService.get_dashboard_data(db))


@router.get("/", status_code=status.HTTP_200_OK)
def get_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user),
):
    return success_response(DashboardService.get_dashboard_data(db))