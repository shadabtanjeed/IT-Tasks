# 4 News App — Hacker News client

A lightweight Flutter client for Hacker News. It demonstrates fetching lists of stories (new, top, best) and displaying them in a clean mobile UI.

Key highlights

- Small, focused Flutter app showcasing REST usage and list navigation
- Uses Dio and http packages for network calls
- Simple router and modular widgets for stories lists

Screenshots (click to enlarge)

New stories:

<a href="https://github.com/user-attachments/assets/c025b2ad-c536-418e-ade0-b04d72d6dd65" target="_blank" rel="noopener noreferrer"><img src="https://github.com/user-attachments/assets/c025b2ad-c536-418e-ade0-b04d72d6dd65" width="280" alt="New stories screenshot"/></a>

Top stories:

<a href="https://github.com/user-attachments/assets/5fa8f396-a77c-45dc-9fef-5282b99ddd75" target="_blank" rel="noopener noreferrer"><img src="https://github.com/user-attachments/assets/5fa8f396-a77c-45dc-9fef-5282b99ddd75" width="280" alt="Top stories screenshot"/></a>

Best stories:

<a href="https://github.com/user-attachments/assets/1257ed7c-4ca0-4af5-bb52-68eb34bb0cd7" target="_blank" rel="noopener noreferrer"><img src="https://github.com/user-attachments/assets/1257ed7c-4ca0-4af5-bb52-68eb34bb0cd7" width="280" alt="Best stories screenshot"/></a>

Getting started

Clone, install dependencies and run the app (requires Flutter):

```bash
git clone https://github.com/shadabtanjeed/IT-Tasks.git
cd 4_news_app
flutter pub get
flutter run
```

Project structure (important files)

- `lib/main.dart` — app entrypoint
- `lib/router.dart` — simple route handling
- `lib/new_stories.dart`, `lib/top_stories.dart`, `lib/best_stories.dart` — story list screens
- `lib/navbar.dart` — bottom navigation

Tech stack

- Flutter
- Dart
- Dio and http (network)

Notes

- The app uses the public Hacker News API (https://github.com/HackerNews/API). No API key required.
- Images in this README are thumbnails that link to the full-size images.


