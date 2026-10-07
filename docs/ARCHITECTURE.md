# Architecture Reference Guide

This document describes the architectural patterns, clean layers, and communication paths applied in the Smart Complaint Analyzer application.

---

## 1. Flutter Mobile App Clean Architecture

The mobile application utilizes a **Feature-Based Clean Architecture** to isolate business rules from native implementations, UI presentation elements, and state management controllers.

```
lib/
├── core/                   # Shared configurations, network clients, routers, constants
│   ├── routing/            # Router configurations (GoRouter)
│   ├── services/           # Network utilities, secure storage, preferences
│   └── theme/              # Visual themes and visual providers
└── features/               # Modular functional app packages
    ├── auth/               # Module handling login, registration, password recoveries
    │   ├── data/           # Remote data sync and repository mappings
    │   ├── domain/         # Pure entities and abstract repositories
    │   └── presentation/   # UI view layouts and riverpod providers/controllers
    ├── onboarding/
    └── profile/
```

### Communication Flow
1. **UI Layer (Widgets)** triggers user events (e.g. login form submission).
2. **Presentation Layer (Providers/Controllers)** receives events, updates view state flags (loading, error), and calls the domain repository.
3. **Domain Layer (Repositories/Entities)** encapsulates business rules and calls data repositories.
4. **Data Layer (Datasources/DTOs)** communicates with backend endpoints (using `Dio`) or native SDKs (using `FirebaseAuth`).

---

## 2. Node.js Backend Architecture

The backend follows a **Modular MVC Architecture** which encapsulates endpoints, validation schemas, and database interaction layers by feature area:

```
src/
├── config/                 # Application database initialization (Mongoose config)
├── middlewares/            # Rate limiting, logger hooks, validation checks, auth guards
├── models/                 # Database schema definitions
├── routes/                 # Express route mappings
├── controllers/            # Controller layers handling request payloads
└── server.js               # Express application wrapper and startup sequence
```
