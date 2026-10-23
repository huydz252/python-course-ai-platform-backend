"""Repair PostgreSQL quiz ID sequences after imports with explicit IDs.

Run from backend/: python -m app.tool.sync_quiz_sequences --apply
Without --apply, this command only reports drift. No application rows are changed.
"""
import argparse
from sqlalchemy import inspect, text
from app.core.database import engine

TABLES = ("quizzes", "quiz_questions", "quiz_options", "quiz_attempts", "quiz_attempt_answers", "learning_activities")


def repair_value(max_id, last_value, is_called):
    if max_id is not None and (last_value < max_id or (last_value == max_id and not is_called)):
        return max(max_id, last_value)
    return None


def sync_sequences(database_engine, apply=False):
    if database_engine.dialect.name != "postgresql":
        raise RuntimeError("This command only supports PostgreSQL.")
    rows = []
    with database_engine.begin() as conn:
        inspector = inspect(conn)
        tables = [table for table in TABLES if inspector.has_table(table)]
        quote = database_engine.dialect.identifier_preparer.quote
        if apply:
            # Block table writes while checking MAX(id), and never lower a sequence.
            conn.execute(text("SET LOCAL lock_timeout = '5s'"))
            conn.execute(text("LOCK TABLE " + ", ".join(quote(t) for t in tables) + " IN SHARE ROW EXCLUSIVE MODE"))
        for table in tables:
            seq = conn.execute(text("SELECT pg_get_serial_sequence(:table, 'id')"), {"table": table}).scalar()
            if not seq:
                continue
            safe_seq = ".".join(quote(part) for part in seq.split("."))
            state = conn.execute(text("SELECT last_value, is_called FROM " + safe_seq)).mappings().one()
            max_id = conn.execute(text("SELECT max(id) FROM " + quote(table))).scalar()
            value = repair_value(max_id, state["last_value"], state["is_called"])
            if apply and value is not None:
                conn.execute(text("SELECT setval(CAST(:seq AS regclass), :value, true)"), {"seq": seq, "value": value})
            rows.append({"table": table, "max_id": max_id, "last_value": state["last_value"],
                         "is_called": state["is_called"], "repair_to": value, "applied": apply and value is not None})
    return rows


if __name__ == "__main__":
    import json
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    for row in sync_sequences(engine, apply=args.apply):
        print(json.dumps(row))
