import os
from datetime import datetime
import google.generativeai as genai
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models import AIChatSession, AIChatMessage
from app.schemas.chatbot import ChatRequest

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_TRANSCRIBE_MODEL = os.getenv("GEMINI_TRANSCRIBE_MODEL")
genai.configure(api_key=GEMINI_API_KEY)

class ChatbotService:
    
    @staticmethod
    async def get_ai_stream_response(request: ChatRequest, user_id: int, db: Session):
        message = request.message
        lesson_id = request.lesson_id
        course_id = request.course_id
        session_id = request.session_id

        # 1. Xử lý Session & Lưu tin nhắn User (Giữ nguyên logic cũ)
        if not session_id:
            new_session = AIChatSession(user_id=user_id, course_id=course_id, lesson_id=lesson_id, title=message[:50])
            db.add(new_session)
            db.commit()
            db.refresh(new_session)
            session_id = new_session.id
        else:
            existing_session = db.query(AIChatSession).filter(AIChatSession.id == session_id).first()
            if existing_session:
                existing_session.updated_at = datetime.utcnow()
                db.commit()

        user_msg = AIChatMessage(session_id=session_id, sender="user", message_text=message)
        db.add(user_msg)
        db.commit()

        system_context = "Bạn là một chuyên gia lập trình Python, nhưng nếu người dùng hỏi những cầu hỏi không liên quan đến python hay lập trình thì hãy trả lời một cách bình thường (không liên quan đến lập trình). Hãy trả lời ngắn gọn, súc tích và dễ hiểu!"
        full_prompt = f"{system_context}\n\nCâu hỏi: {message}"

        # 3. Hàm generator để stream chữ từ Gemini
        async def event_generator():
            full_reply = ""
            try:
                model = genai.GenerativeModel(GEMINI_TRANSCRIBE_MODEL)
                # Bật stream=True để nhận phản hồi theo từng cụm từ
                response = await model.generate_content_async(full_prompt, stream=True)
                
                async for chunk in response:
                    if chunk.text:
                        full_reply += chunk.text
                        # Gửi từng mảnh text qua stream
                        yield chunk.text

                # Sau khi stream xong, lưu toàn bộ câu trả lời của AI vào Database
                ai_msg = AIChatMessage(
                    session_id=session_id,
                    sender="assistant",
                    message_text=full_reply,
                    model_name=GEMINI_TRANSCRIBE_MODEL
                )
                db.add(ai_msg)
                db.commit()

            except Exception as e:
                db.rollback()
                yield f"\n[Lỗi kết nối AI: {str(e)}]"

        return session_id, event_generator()
            
    @staticmethod
    def get_user_sessions(user_id: int, db: Session):
        """Lấy danh sách lịch sử chat của user"""
        return db.query(AIChatSession)\
                 .filter(AIChatSession.user_id == user_id)\
                 .order_by(AIChatSession.updated_at.desc())\
                 .all()

    @staticmethod
    def get_session_messages(session_id: int, user_id: int, db: Session):
        """Lấy danh sách tin nhắn thuộc về 1 session, có check quyền bảo mật"""
        # Kiểm tra xem session có tồn tại và có phải của user này không
        session = db.query(AIChatSession).filter(
            AIChatSession.id == session_id, 
            AIChatSession.user_id == user_id
        ).first()
        
        if not session:
            raise HTTPException(status_code=403, detail="Không có quyền truy cập hoặc cuộc trò chuyện không tồn tại!")

        # Nếu hợp lệ thì mới query tin nhắn
        return db.query(AIChatMessage)\
                 .filter(AIChatMessage.session_id == session_id)\
                 .order_by(AIChatMessage.created_at.asc())\
                 .all()