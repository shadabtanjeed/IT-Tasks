# ollama_chatbot

Minimal Flutter chat client for local Ollama model testing.

Features

- Animated loading screen for chat history
- Swipe to delete chats

Prerequisites

- Flutter SDK
- Ollama running locally (example):
  OLLAMA_HOST=0.0.0.0 ollama serve

Quick start

1. Update the host override in `lib/pages/chat_page.dart` to match your machine IP if needed.
2. (Optional) Enable thinking animation via the `enableThinking` variable in `lib/pages/chat_page.dart`.

Run

```bash
flutter pub get
flutter run
```

Notes

- This project targets Android during development. Adjust platform/device as needed.
- If Ollama is not reachable, chat requests will fail — verify the host and that Ollama is running.
