# SUPERBAI - Maid Service Booking App

SUPERBAI is a Flutter-based mobile application that allows users to book maid services seamlessly. This repository contains the full source code for the app, integrated with Firebase for authentication and backend functionality.

---

## 🔧 Features

- User Registration & Login
- Service Booking
- Real-time Updates
- Firebase Integration (Authentication, Firestore)
- Modern UI built with Flutter

---

---

## 🛠️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/superbai.git
cd superbai
```

### 2. Install Dependencies

```bash
flutter pub get
```

---

## 🔐 Firebase Setup (Using CLI)

Make sure you have connected Firebase to your Flutter project using CLI. Follow the below steps if you're setting up Firebase on a new machine or sharing this project with others:

### Step 1: Login to Firebase

```bash
firebase login
```

### Step 2: Initialize Firebase in the project

Ensure you are in the project root directory:

```bash
firebase init
```

During setup, choose:

- **Firestore** or **Authentication** based on your app's requirement
- Choose `lib/firebase_options.dart` or auto-detect based on your `firebase.json`

### Step 3: Configure Firebase for Flutter (Using flutterfire_cli)

```bash
flutterfire configure
```

This command will:

- Link your Flutter app to your Firebase project
- Generate `firebase_options.dart` with the correct configuration for all platforms

Make sure to import this file in your `main.dart`:

```dart
import 'firebase_options.dart';
```

## 📱 Run the App

```bash
flutter run
```

---

## 📦 Build APK

```bash
flutter build apk --release
```
