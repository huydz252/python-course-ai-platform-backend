"""Model order and short, per-process cooldowns for Gemini chat."""
import os
from time import monotonic


def parse_models(value):
    return tuple(dict.fromkeys(
        name.strip().removeprefix("models/")
        for name in value.split(",") if name.strip()
    ))


def configured_models():
    explicit = parse_models(os.getenv("GEMINI_CHAT_MODELS", ""))
    if explicit:
        return explicit
    primary = os.getenv("GEMINI_CHAT_MODEL") or "gemini-3.5-flash-lite"
    return parse_models(primary)


def fallback_reason(error):
    # Use the SDK status, never guess quota exhaustion from an error message.
    code = getattr(error, "code", None)
    if callable(code):
        code = code()
    if code == 429:
        return "quota", 60
    if code == 404:
        return "unavailable", 3600
    return None


class ModelCooldowns:
    def __init__(self):
        self.until = {}

    def available(self, model):
        return self.until.get(model, 0) <= monotonic()

    def block(self, model, seconds):
        self.until[model] = monotonic() + seconds


class NoChatModelAvailable(Exception):
    pass
