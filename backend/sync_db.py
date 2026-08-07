from app.core.database import engine, Base
# Import tất cả các model để SQLAlchemy nhận diện được
from app.models.courses_model import *
from app.models.users_model import *
from app.models.quizzes_model import *
from app.models.ai_pipeline_model import * 
from app.models.system_model import *

print("Đang tạo các bảng trên Supabase...")
Base.metadata.create_all(bind=engine)
print("Thành công! Khởi động lại server thôi!")