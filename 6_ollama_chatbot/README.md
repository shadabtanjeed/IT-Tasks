# ollama_chatbot

Minimal Flutter chat client for local Ollama model testing.

Features

- Animated loading screen
- Swipe to delete chats

Prerequisites

- Flutter SDK
- Ollama running locally (example):
  OLLAMA_HOST=0.0.0.0 ollama serve

### Screenshots

<p>
  <img src="https://github.com/user-attachments/assets/b35c6c06-f5a9-40c1-98a9-43783145e787" alt="Chat page" width="360" style="max-width:100%;height:auto;margin-right:8px;" />
  <img src="https://github.com/user-attachments/assets/3c77b350-dc9d-4f94-92fd-c714df4dbd23" alt="Chat page 2" width="360" style="max-width:100%;height:auto;margin-right:8px;" />
</p>

<p>
  <img src="https://github.com/user-attachments/assets/71eef5ff-0355-4507-b506-f27a777538aa" alt="Chat History" width="360" style="max-width:100%;height:auto;" />
</p>

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
