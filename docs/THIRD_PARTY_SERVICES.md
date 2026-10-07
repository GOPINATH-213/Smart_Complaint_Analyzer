# Third-Party Services Configuration Guide

This document details the account setups, portal configurations, and asset steps required to connect external services.

---

## 1. Firebase Authentication & Google Sign-In
Firebase handles student and staff identity validation.
* **Flutter Config**: Generated automatically by the **FlutterFire CLI** into `lib/firebase_options.dart`. Do not manually declare Firebase credentials in client `.env` files.
* **Backend Config**: The backend uses the `firebase-admin` SDK. Create a service account in Firebase Console -> Project Settings -> Service Accounts. Download the private key credentials JSON, and inject the parsed parameters into the backend environment configuration:
  * `FIREBASE_PROJECT_ID`
  * `FIREBASE_CLIENT_EMAIL`
  * `FIREBASE_PRIVATE_KEY` (ensure newline characters `\n` are escaped properly)
  * `FIREBASE_STORAGE_BUCKET`

---

## 2. MongoDB Atlas Database
MongoDB Atlas houses user profiles and complaint documents.
* Set IP Access List values to `0.0.0.0/0` under Network Access to allow Render backend hosting access.
* Inject connection string into `MONGODB_URI` environment variable.

---

## 3. Google Gemini AI API
Gemini powers classification, summarization, and priority analysis (Phase 2+).
* Obtain an API Key from the [Google AI Studio Console](https://aistudio.google.com/).
* Save the credentials key in the backend environment file under `GEMINI_API_KEY`.
* Choose the engine model target (`gemini-1.5-flash` or `gemini-1.5-pro`) and specify it in `GEMINI_MODEL`.

---

## 4. Cloudinary Image Storage
Cloudinary hosts user avatar photos and resolution proofs (Phase 3+).
* Configure credentials (`CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`) on the backend.
* For security, the mobile app never uploads assets directly. All uploads route through the backend configuration layer.

---

## 5. Firebase Cloud Messaging (FCM)
FCM manages push notifications for system updates (Phase 4+).
* *Note: OneSignal configurations are fully removed from this project.*
* FCM configurations are handled on the client using Firebase native services, and on the backend using the authorized Firebase Admin SDK instance.

---

## 6. Brevo Email Service
Brevo delivers email verification messages and admin notifications (replacing old legacy SMTP hosts).
* Sign up for a developer account at [Brevo](https://www.brevo.com/).
* Generate an API Key under SMTP & API Settings.
* Save the values to the backend environment variables:
  * `BREVO_API_KEY`
  * `BREVO_SENDER_EMAIL` (authorized sending domain)
  * `BREVO_SENDER_NAME` (sender identity profile)
