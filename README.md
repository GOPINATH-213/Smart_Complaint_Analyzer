# Smart Complaint Analyzer

An AI-Powered Complaint Classification and Prioritization System. The application consists of a **Flutter mobile application** (frontend) and a **Node.js Express server** (backend) connected to **MongoDB**.

---

## Prerequisites

Before starting, ensure you have the following installed on your system:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable)
* [Node.js & npm](https://nodejs.org/en) (v20+ recommended)
* [MongoDB](https://www.mongodb.com/try/download/community) (Local community server or MongoDB Atlas cluster)

---

## Project Structure

```
Smart Compliant Analyzer/
├── smart_complaint_backend/     # Node.js + Express + MongoDB Backend
└── smart_complaint_app/         # Flutter Mobile Application (Clean Architecture)
```

---

## 🚀 Backend Setup

1. **Navigate to the backend directory**:
   ```bash
   cd smart_complaint_backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure Environment Variables**:
   * Duplicate the `.env.example` file and rename it to `.env`.
   * Fill in your configuration values:
     ```env
     PORT=5000
     MONGODB_URI=mongodb://localhost:27017/smart_complaint_analyzer
     GEMINI_API_KEY=your_gemini_api_key_here
     CLOUDINARY_CLOUD_NAME=your_cloud_name_here
     CLOUDINARY_API_KEY=your_api_key_here
     CLOUDINARY_API_SECRET=your_api_secret_here
     ```

4. **Run the server**:
   * For **Development** (hot-reload with nodemon):
     ```bash
     npm run dev
     ```
   * For **Production**:
     ```bash
     npm start
     ```

---

## 📱 Frontend (Flutter) Setup

1. **Navigate to the app directory**:
   ```bash
   cd smart_complaint_app
   ```

2. **Fetch packages**:
   ```bash
   flutter pub get
   ```

3. **Setup Firebase Configuration**:
   * Create a project in the [Firebase Console](https://console.firebase.google.com/).
   * Register an Android/iOS app with the package name: `com.klnce.smartcomplaint.smart_complaint_app`.
   * Download the `google-services.json` (for Android) and place it in the `smart_complaint_app/android/app/` folder.
   * Enable **Email/Password** and **Google Sign-In** under Firebase Authentication.

4. **Verify codebase formatting & analysis**:
   ```bash
   flutter analyze
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🌐 Local Network Configuration Note

* The Flutter client automatically communicates with the Express backend using `http://10.0.2.2:5000` on the Android emulator and `http://localhost:5000` on the iOS simulator or Web browser.
* Ensure the backend server is running before logging in or completing profiles on the mobile app.
