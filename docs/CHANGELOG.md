# Changelog

All notable changes to the Smart Complaint Analyzer system will be documented in this file.

---

## [1.0.0-phase1] - 2026-08-03
### Added
* **Architecture Setup**: Configured Feature-Based Clean Architecture on the mobile app, and Modular MVC structure on the Express backend.
* **Database Models**: Created Mongoose User schema supporting both Student and Staff profiles.
* **Authentication Flow**: Added Firebase Auth and Google Sign-In repositories.
* **College Email Logic**: Added automatic register number parser matching `@klnce.edu` domain formats.
* **Dynamic Views**: Created Splash, Onboarding Carousel, Login, User Type selection, Verify Email waiting, Profile Completion forms, Settings switcher, and Dashboard stub screens.
* **Multi-Environment Setup**: Added `.env.example`, `.env.development`, and `.env.production` files.
* **Documentation**: Initialized `docs/` folder containing Architecture, Project Structure, API, Database, Setup, and Roadmap reference guides.

## [1.0.1-cleanup] - 2026-08-04
### Changed
* **Centralized Configuration Layer**: Implemented centralized configurations in both components: `app_config.dart` & `environment.dart` for Flutter, and `src/config/index.js` (and submodules) for the Node.js backend.
* **Fail-Fast Validations**: Added startup environment validations to both apps, crashing immediately with detailed error outputs if required parameters are missing.
* **Removed Firebase client keys from env**: Deleted redundant Firebase properties from Flutter's `.env` files since configurations are supplied directly by `firebase_options.dart`.
* **Swapped legacy SMTP for Brevo API**: Removed SMTP server credentials from the backend, replacing them with Brevo API parameters.
* **FCM Push Notification switch**: Replaced OneSignal configuration parameters in the project with Firebase Cloud Messaging (FCM) configurations.
* **Removed direct Cloudinary presets on client**: Removed Cloudinary preset details from Flutter environment variables (uploads will route securely through the backend configuration layer).

