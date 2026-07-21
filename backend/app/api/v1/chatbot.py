import os
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.chatbot import ChatRequest
import google.generativeai as genai
from app.services.chatbot_service import ChatbotService 

from app.core.database import get_db
from app.models.users_model import User
from app.services.user_service import UserService
from app.utils.response import success_response
from fastapi.responses import StreamingResponse

router = APIRouter()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)



@router.post("/ask")
async def ask_ai_stream(
    request: ChatRequest,
    current_user: User = Depends(UserService.get_current_user),
    db: Session = Depends(get_db)
):
    session_id, generator = await ChatbotService.get_ai_stream_response(
        request=request,
        user_id=current_user.id,
        db=db
    )
    
    # Trả về kèm session_id qua custom header để Frontend biết và đồng bộ
    return StreamingResponse(
        generator, 
        media_type="text/plain",
        headers={"X-Session-Id": str(session_id)}
    )
    
@router.get("/sessions")
async def get_chat_sessions(
    current_user: User = Depends(UserService.get_current_user),
    db: Session = Depends(get_db)
):
    """Lấy danh sách lịch sử chat của user hiện tại"""
    sessions = ChatbotService.get_user_sessions(user_id=current_user.id, db=db)
    return success_response(data=sessions, message="Lấy danh sách thành công")

@router.get("/sessions/{session_id}/messages")
async def get_session_messages(
    session_id: int,
    current_user: User = Depends(UserService.get_current_user),
    db: Session = Depends(get_db)
):
    """Lấy danh sách tin nhắn thuộc về 1 session"""
    messages = ChatbotService.get_session_messages(
        session_id=session_id, 
        user_id=current_user.id, 
        db=db
    )
    return success_response(data=messages, message="Lấy tin nhắn thành công")