# Chat model configuration

Set these variables in `backend/.env` and restart the backend:

```dotenv
GEMINI_CHAT_MODEL=gemini-3.5-flash-lite
GEMINI_CHAT_MODELS=gemini-3.5-flash-lite,gemini-3.6-flash,gemini-3.8-flash
```

`GEMINI_CHAT_MODELS` takes priority over the single-model variable. The first
three distinct models are tried in order. If no list is configured, the backend
uses only `GEMINI_CHAT_MODEL`. Transcript generation still uses its own variable,
`GEMINI_TRANSCRIBE_MODEL`.

Before any response text reaches the client:

- HTTP 429: skip that model for 60 seconds and try the next one.
- HTTP 404: skip that model for one hour and try the next one.
- Other errors, including timeouts and authentication errors, do not trigger a
  model switch.

Cooldowns are held in memory per backend process and reset on restart. A cooldown
does not mean the provider's quota has reset; exhausted daily quotas can continue
to return 429 after the cooldown. Models may share provider quotas. No additional
project or API key is created.

The total request deadline remains 90 seconds. The SDK's automatic retries are
disabled so the application controls the attempts. Once text has streamed, an
error ends that response rather than mixing outputs from different models.

Look for `AI attempt`, `AI fallback`, `AI skip`, and `AI complete` in the backend
logs. Successful messages record the actual model name in the database. When all
candidates are unavailable or cooling down, the user receives an explicit message.

The configured model IDs and quota availability still need to be verified with
the project's real API key. Unit tests use a fake provider and an isolated SQLite
database; they do not consume API quota:

```powershell
python -m pytest backend/tests/test_chatbot_context.py -q
```
