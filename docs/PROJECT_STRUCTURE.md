# Project Structure Blueprint

This document maps out the absolute directory organization for both the Flutter application and the Express backend.

---

## 1. Frontend Mobile Directory Structure

```
smart_complaint_app/
├── lib/
│   ├── main.dart                       # App initialization logic
│   ├── core/
│   │   ├── routing/
│   │   │   └── app_router.dart         # GoRouter configurations
│   │   ├── services/
│   │   │   ├── api_service.dart        # Dio API client wrapper
│   │   │   └── secure_storage.dart     # Keystore/Keychain credentials manager
│   │   └── theme/
│   │       ├── app_theme.dart          # Light/Dark visual themes
│   │       └── theme_provider.dart     # Riverpod theme mode state notifier
│   └── features/
│       ├── auth/                       # Phase 1: Authentication module
│       │   ├── data/
│       │   │   └── auth_repository.dart
│       │   └── presentation/
│       │       └── screens/
│       │           ├── login_screen.dart
│       │           └── register_screen.dart
│       ├── onboarding/                 # Phase 1: Initial startup walkthroughs
│       ├── profile/                    # Phase 1: Student and Staff profile management
│       │   └── presentation/
│       │       └── screens/
│       │           ├── home_stub_screen.dart
│       │           └── settings_screen.dart
│       ├── complaints/                 # [FUTURE] Phase 2: Complaint submission
│       ├── ai_analysis/                # [FUTURE] Phase 2: AI summaries & details view
│       ├── notifications/              # [FUTURE] Phase 4: Push/Local notifications
│       └── analytics/                  # [FUTURE] Phase 5: fl_chart based analytics
```

---

## 2. Backend Server Directory Structure

```
smart_complaint_backend/
├── src/
│   ├── server.js                       # Main express launcher
│   ├── config/
│   │   └── db.js                       # Database connection configuration
│   ├── controllers/
│   │   └── userController.js           # User credentials profiles controller
│   ├── middlewares/
│   │   ├── errorMiddleware.js          # Central error logging
│   │   ├── rateLimiter.js              # DOS prevention limiter
│   │   └── authMiddleware.js           # Firebase JWT verification hooks
│   ├── models/
│   │   └── User.js                     # Unified User model schema
│   ├── routes/
│   │   └── userRoutes.js               # API user routes
│   └── features/                       # Placeholder directories for modular features
│       ├── complaints/                 # [FUTURE] Phase 2: Complaint controllers/models
│       ├── ai/                         # [FUTURE] Phase 2: Gemini prompting
│       └── notifications/              # [FUTURE] Phase 4: OneSignal/FCM syncs
```
