from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    lesson_id: Optional[int] = None
    course_id: Optional[int] = None
    session_id: Optional[int] = None