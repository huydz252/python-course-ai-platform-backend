import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app.tool.sync_quiz_sequences import repair_value


def test_seeded_ids_require_sequence_repair():
    assert repair_value(2, 1, False) == 2
    assert repair_value(7, 1, False) == 7
    assert repair_value(1, 1, False) == 1


def test_existing_healthy_sequences_are_never_lowered():
    assert repair_value(7, 7, True) is None
    assert repair_value(7, 50, True) is None
    assert repair_value(7, 50, False) is None
    assert repair_value(None, 1, False) is None
