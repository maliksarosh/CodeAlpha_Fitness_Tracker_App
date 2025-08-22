# FitTrack - A Modern Fitness Tracker App

A sleek, feature-rich fitness tracking application built entirely with Flutter and Firebase. This
app provides a complete, cloud-synced experience for users to log, track, and visualize their
workout progress with a beautiful and intuitive user interface.

## App Demo

*(It is highly recommended to replace this image with a GIF of your app in action!)*

![App Demo GIF](https://your-gif-url-here.com/demo.gif)

---

## 📋 Table of Contents

- [About The Project](#about-the-project)
- [✨ Features](#-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [📸 Screenshots](#-screenshots)
- [🚀 Getting Started](#-getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [📂 Project Structure](#-project-structure)

---

## 📖 About The Project

FitTrack was built to provide a seamless and motivating fitness tracking experience. It combines a
fast, responsive UI with secure cloud-based data storage, ensuring the user's data is always safe
and accessible across devices. The project started as a step-by-step learning journey and evolved
into a full-stack mobile application, showcasing modern Flutter development practices.

---

## ✨ Features

### Core Functionality

- **🔐 Secure User Authentication:** Full signup, login, and logout functionality powered by Firebase
  Authentication.
- **👤 User Onboarding:** A smooth flow for new users to create an account and set up their profile (
  name, gender).
- **☁️ Cloud Data Storage:** All user profile and activity data is stored securely in Cloud
  Firestore, linked to the user's account.
- **🏋️ Activity Logging:** An intuitive bottom sheet allows users to add new workouts with details
  like type, duration, and calories burned.
- **🗑️ Manage Activities:** Users can easily delete logged activities with a confirmation dialog
  using a swipe-to-delete gesture.

### UI & UX

- **🎨 Dual Theming:** A beautiful, custom "Soft Light" theme and a "Shiny Black" dark theme.
- **⚙️ User Settings:** A dedicated settings screen where users can manually toggle the theme and
  edit their personal information.
- **🎯 Dynamic Daily Goals:** Users can set and update their personal daily exercise goal, which is
  saved to their cloud profile.
- **📊 Interactive Dashboard:** The dashboard features a dynamic progress circle that tracks the
  user's progress against their daily goal.
- **📈 Advanced Visualization:** A dedicated History screen with an interactive monthly bar chart to
  visualize workout duration and consistency over time.
- **🚀 Polished Experience:** Includes a branded splash screen, elegant animations, and contextual
  prompts to guide the user.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Programming Language:** [Dart](https://dart.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/)
    - **Authentication:** Firebase Authentication
    - **Database:** Cloud Firestore
- **State Management:** `StatefulWidget` & `Provider` (for theming)
- **Key Packages:**
    - `firebase_core`, `firebase_auth`, `cloud_firestore`
    - `fl_chart` for data visualization
    - `provider` for theme management
    - `iconsax` for the icon pack
    - `shared_preferences` for storing the daily goal
    - `percent_indicator` for the progress circle

---

## 📸 Screenshots

*(Replace these with your own screenshots!)*

|                Dashboard (Dark)                |                History (Light)                |                 Profile Screen                 |
|:----------------------------------------------:|:---------------------------------------------:|:----------------------------------------------:|
| ![Dashboard Dark](link-to-your-screenshot.png) | ![History Light](link-to-your-screenshot.png) | ![Profile Screen](link-to-your-screenshot.png) |

|                 Welcome Screen                 |                 Login Screen                 |              Add Activity Sheet              |
|:----------------------------------------------:|:--------------------------------------------:|:--------------------------------------------:|
| ![Welcome Screen](link-to-your-screenshot.png) | ![Login Screen](link-to-your-screenshot.png) | ![Add Activity](link-to-your-screenshot.png) |

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- **Flutter SDK:** Make sure you have the Flutter SDK
  installed. [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Firebase Account:** You will need a free Firebase
  account. [Create Account](https://firebase.google.com/)

### Installation

1. **Clone the repo**
   ```sh
   git clone https://github.com/your_username/your_repository_name.git
   ```
2. **Navigate to the project directory**
   ```sh
   cd fitness_tracker_app
   ```
3. **Install packages**
   ```sh
   flutter pub get
   ```
4. **Set up Firebase**
    - Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    - In the project, go to **Authentication** -> **Sign-in method** and enable **Email/Password**.
    - Go to **Cloud Firestore** and create a database. Start in **test mode**.
    - Follow the instructions to install the FlutterFire CLI:
      `dart pub global activate flutterfire_cli`.
    - Run the login command: `firebase login`.
    - Finally, connect your project by running the configure command and selecting your project:
      ```sh
      flutterfire configure
      ```
   This will automatically generate your `lib/firebase_options.dart` and
   `android/app/google-services.json` files.

5. **Run the app**
   ```sh
   flutter run
   ```

---

## 📂 Project Structure

The project follows a standard feature-first folder structure to keep the code organized and
scalable.

lib/
├── data/
│ └── database_helper.dart # Manages legacy local user data (can be removed)
├── models/
│ ├── activity.dart # Data model for a workout
│ └── user.dart # Data model for user profile (legacy)
├── screens/
│ ├── auth/ # Contains all authentication screens
│ │ ├── login_screen.dart
│ │ ├── signup_screen.dart
│ │ ├── user_details_screen.dart
│ │ └── welcome_screen.dart
│ ├── add_activity_screen.dart # Bottom sheet for adding new workouts
│ ├── dashboard_screen.dart # The main dashboard
│ ├── edit_profile_screen.dart # Screen for editing user info
│ ├── history_screen.dart # Screen with the monthly chart
│ ├── main_screen.dart # The main app shell with the nav bar
│ ├── profile_screen.dart # User profile and stats
│ ├── settings_screen.dart # App settings
│ └── splash_screen.dart # Initial splash screen
├── theme/
│ ├── app_theme.dart # Defines the light and dark themes
│ └── theme_provider.dart # Manages theme state
└── main.dart # The main entry point of the app