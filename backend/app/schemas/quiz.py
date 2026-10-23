from typing import Literal
from pydantic import BaseModel, Field, model_validator


class QuizOptionInput(BaseModel):
    label: Literal["A", "B", "C", "D"]
    content: str = Field(min_length=1, max_length=3000)


class QuizQuestionInput(BaseModel):
    question: str = Field(min_length=1, max_length=5000)
    code: str | None = Field(default=None, max_length=10000)
    difficulty: Literal["easy", "medium", "hard"] = "easy"
    options: list[QuizOptionInput] = Field(min_length=4, max_length=4)
    correctLabel: Literal["A", "B", "C", "D"]
    explanation: str = Field(min_length=1, max_length=5000)

    @model_validator(mode="after")
    def distinct_options(self):
        if {option.label for option in self.options} != {"A", "B", "C", "D"}:
            raise ValueError("Mỗi câu cần đủ lựa chọn A, B, C, D.")
        if len({option.content.strip().casefold() for option in self.options}) != 4:
            raise ValueError("Các lựa chọn không được trùng nhau.")
        if not self.question.strip() or not self.explanation.strip() or any(not o.content.strip() for o in self.options):
            raise ValueError("Câu hỏi, lựa chọn và giải thích không được để trống.")
        return self


class QuizDraftInput(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    durationSeconds: int = Field(default=600, ge=0, le=7200)
    questions: list[QuizQuestionInput] = Field(min_length=1, max_length=20)


class QuizGenerateInput(BaseModel):
    count: int = Field(default=5, ge=1, le=10)
    durationSeconds: int = Field(default=600, ge=0, le=7200)


class QuizAnswerInput(BaseModel):
    questionId: int = Field(gt=0)
    optionId: int | None = Field(default=None, gt=0)


class QuizSubmitInput(BaseModel):
    attemptToken: str = Field(min_length=1, max_length=5000)
    answers: list[QuizAnswerInput] = Field(max_length=20)
