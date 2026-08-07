from fastapi import APIRouter, status, Depends, HTTPException
from sqlalchemy.orm import Session

from app.schemas.auth import UserRegisterInput, UserLoginInput, GoogleLoginInput
from app.services.auth_service import AuthService
from app.core.database import get_db

router = APIRouter()

@router.post("/google-login")
def google_login(login_input: GoogleLoginInput, db: Session = Depends(get_db)):
    result = AuthService.google_login(login_input, db=db)
    
    # Xử lý an toàn để tránh lỗi AttributeError khi gọi .value
    user_role = result["user"].role.value if hasattr(result["user"].role, 'value') else result["user"].role
    
    return {
        "status": "success",
        "message": "Đăng nhập bằng Google thành công!",
        "access_token": result["access_token"],
        "token_type": result["token_type"],
        "user": {
            "id": result["user"].id,
            "username": result["user"].username,
            "role": user_role
        }
    }

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(user_data: UserRegisterInput, db: Session = Depends(get_db)):
    saved_user = AuthService.register_user(user_data, db=db)
    if not saved_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, 
            detail="Username hoặc Email đã được sử dụng!"
        )
        
    # Bóc tách Model SQLAlchemy thành Dict để FastAPI serialize thành JSON mượt mà
    user_role = saved_user.role.value if hasattr(saved_user.role, 'value') else saved_user.role
    
    return {
        "status": "success",
        "message": "Đăng ký tài khoản thành công!",
        "data": {
            "id": saved_user.id,
            "username": saved_user.username,
            "email": saved_user.email,
            "role": user_role
        }
    }
    
@router.post("/login")
def login(login_input: UserLoginInput, db: Session = Depends(get_db)):
    result = AuthService.authenticate_user(
        username=login_input.username, 
        password=login_input.password,
        db=db
    )
    if not result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Tài khoản hoặc mật khẩu không chính xác"
        )
        
    user_role = result["user"].role.value if hasattr(result["user"].role, 'value') else result["user"].role
        
    return {
        "status": "success",
        "message": "Đăng nhập thành công!",
        "access_token": result["access_token"],
        "token_type": "bearer",
        "user": {
            "id": result["user"].id,
            "username": result["user"].username,
            "email": result["user"].email,
            "fullName": result["user"].full_name,
            "avatarUrl": getattr(result["user"], "avatar_url", ""), 
            "role": user_role
        }
    }