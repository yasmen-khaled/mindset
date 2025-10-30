# Mindset App – Full Project Documentation

Version: 1.0

## 1) Overview

Mindset is a Flutter application with a Go (Gin) backend. It provides:
- Account management with phone-based auth (international phone handling)
- Personalized onboarding and learning-path selection
- Three distinct Home experiences based on the selected path:
  - Software Engineering (original map-based home)
  - Tamazight Language (6 grades)
  - Academic Courses (12 grades)
- Levels → Tasks → Quiz flow
- Games module (Memory Game implemented)
- Local persistence (SharedPreferences)
- Backend APIs for login, registration, password reset via SMS

This document explains code structure, how pages and services work, what we changed, and how to run the whole stack.

## 2) Project Structure

```
mindset/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── splash.dart
│   │   ├── onboarding.dart
│   │   ├── login.dart
│   │   ├── SignUp.dart
│   │   ├── selection.dart
│   │   ├── welcome.dart
│   │   ├── home.dart                    # Software Engineering home
│   │   ├── home_tmazight.dart           # Tamazight home (6 grades)
│   │   ├── home_academic.dart           # Academic home (12 grades)
│   │   ├── home_router.dart             # Chooses home by learning path
│   │   ├── catagory.dart                # Level topics list (6)
│   │   ├── tasks.dart                   # Level detail + tasks + Quiz entry
│   │   ├── Quiz.dart                    # Quiz UI + timer
│   │   ├── Result.dart                  # Quiz result
│   │   ├── games.dart                   # Games hub
│   │   ├── memory_game.dart             # Memory game
│   │   ├── Repassword.dart              # SMS reset (full flow)
│   │   ├── simple_reset.dart            # Simple reset (no SMS)
│   │   └── done.dart                    # (commented example)
│   ├── services/
│   │   ├── api_service.dart             # HTTP client to Go backend
│   │   ├── country_service.dart         # Country/phone utils
│   │   └── storage_service.dart         # SharedPreferences layer
│   └── widgets/
│       └── country_picker.dart          # Reusable picker + phone input
├── backend/
│   ├── simple_server.go                 # Gin server (MySQL or in-memory)
│   ├── database_schema.sql
│   ├── SETUP_GUIDE.md
│   └── ...
└── docs/
    └── PROJECT_DOCUMENTATION.md         # This document
```

## 3) App Flow and Routing

- App entry: `lib/main.dart`
  - `initialRoute` → `/splash`
  - Routes defined for splash, onboarding, login, signup, forgot/simple-reset, home, games, memory-game, selection, welcome.
  - `/home` renders `HomeRouter(username: ...)` which decides which home page to show based on the saved learning path.

- Splash: `pages/splash.dart`
  - Waits ~2 seconds, checks login via `StorageService.isLoggedIn()`.
  - If logged in → navigates to `/home` with stored username.
  - Else → `/onboarding`.

- Onboarding: `pages/onboarding.dart`
  - Swipable pages with CTA to proceed to `/login`.

- Auth:
  - Login `pages/login.dart`: Country-aware phone input + password.
  - SignUp `pages/SignUp.dart`: Country-aware phone + password + gender.
  - Both call `ApiService` to hit Go backend; upon success, data saved via `StorageService.saveLoginData()`.

- Selection: `pages/selection.dart`
  - User chooses a learning path (software_engineering / tmazight_language / academic_courses), app language, (optional) academic level, and (optional) Tmazight script.
  - Saves with `StorageService.saveUserPreferences()`, then navigates to welcome.

- Welcome: `pages/welcome.dart`
  - Short animated welcome; then navigates to `/home`.

- Home: `pages/home_router.dart`
  - Reads `learning_path` from `StorageService.getUserPreferences()`.
  - Renders one of:
    - Software Engineering home: `pages/home.dart` (map-like with glowing buttons, leaderboard, settings, avatar shop, life shop, team, etc.)
    - Tamazight home: `pages/home_tmazight.dart` (grid of 6 grades)
    - Academic home: `pages/home_academic.dart` (grid of 12 grades)

- Levels and Tasks:
  - `pages/catagory.dart` shows 6 topic levels. On tap, navigates to `LevelDetailPage` and returns a value to unlock next level on success.
  - `pages/tasks.dart` (`LevelDetailPage`) shows tasks and a “Done?” button which opens `QuizPage`.
  - Completing the quiz returns true to unlock next level and then returns you back toward home.

- Games:
  - `pages/games.dart` hub; `pages/memory_game.dart` fully implemented.

## 4) Core Services and Utilities

### 4.1 `services/storage_service.dart`
- Uses `SharedPreferences`.
- Keys: auth token, username, phone number, `is_logged_in`.
- Preferences: `learning_path`, `app_language`, optional `academic_level`, optional `tmazight_script`, `gender`.
- Methods:
  - `saveLoginData`, `isLoggedIn`, `getToken`, `getUsername`, `getPhoneNumber`, `getUserData`, `clearLoginData`, `updateUsername`.
  - Preferences helpers: `saveUserPreferences`, `getUserPreferences`, `updateLearningPath`, `updateAppLanguage`, `saveGender`, `getGender`.

Why: Centralizes persistence. Where used: login/signup flows, home initialization, selection, profile edits.

### 4.2 `services/api_service.dart`
- Base URL: `http://localhost:8005/webstudent`
- Endpoints used:
  - `POST /login` { phone_number, password }
  - `POST /register` { username, phone_number, password, gender }
  - `POST /send_sms_reset` { phone_number }
  - `POST /verify_sms_reset` { phone_number, verification_code, new_password }
  - `POST /reset_password` { phone_number, new_password }
  - `POST /update_password` { old_password, new_password } (requires token)
  - `POST /get_profile`
- Utility phone helpers for formatting and country detection (frontend-facing convenience for display).

Why: Isolates HTTP logic and response mapping.

### 4.3 `services/country_service.dart` and `widgets/country_picker.dart`
- Large curated list of countries (Arab world and global) with flag, phone code, example number.
- Searchable bottom-sheet picker + composite `CountryPhoneField` (picker + input) to ensure numbers are correctly formatted and validated per country.

Why: Accurate phone capture for international users.

## 5) Home Experiences

### 5.1 Home Router `pages/home_router.dart`
- Reads saved `learning_path` and returns:
  - `HomePage` for `software_engineering`
  - `TmazightHomePage` for `tmazight_language`
  - `AcademicHomePage` for `academic_courses`

Why: Single `/home` route; clean extensibility for more paths later.

### 5.2 Software Engineering Home `pages/home.dart`
- Background: lighter blue gradient overlayed on map/SVG assets (recently lightened).
- Animated glowing buttons (levels 1–7) that push `LevelTopicsPage`.
- Rich top bars with stars, smart, lives (with shop modal).
- Leaderboard modal with profile pages.
- Profile settings modal:
  - Edit name (persists via `StorageService.updateUsername`)
  - Learning Path settings (saves via `StorageService.updateLearningPath`)
  - App Language settings (saves via `StorageService.updateAppLanguage`)
  - Avatar shop (select/unlock skins)
  - Logout (clears storage and navigates to login)
- “Team” modal card navigator.

Where: Entry from Splash/Welcome/Router. Why: Gamified learning journey with cosmetic UX.

### 5.3 Tamazight Home `pages/home_tmazight.dart`
- Grid of 6 grades (cards with icon, title, hint). Tapping opens `LevelTopicsPage` (placeholder for grade-specific content).
- Header includes quick swap to software engineering (updates learning path and pushes `/home`).
- Lightened blue gradient theme.

### 5.4 Academic Home `pages/home_academic.dart`
- Grid of 12 grades, same interaction model as Tamazight.
- Header swap and lightened gradient as well.

## 6) Levels, Tasks, and Quiz

- `pages/catagory.dart` (LevelTopicsPage):
  - Shows 6 levels. On tap, navigates to `LevelDetailPage` and returns a value to unlock next level on success.
  - Bottom nav now uses `Navigator.pushReplacementNamed(context, '/home')` for Home.

- `pages/tasks.dart` (LevelDetailPage):
  - Decorative modal with intro content, progress bars, and a “Done?” button.
  - “Done?” opens `QuizPage`; returning unlocks next level.

- `pages/Quiz.dart`:
  - 5 questions with a global timer and automatic navigation to `ResultPage` on completion/timeout.

- `pages/Result.dart`:
  - Displays a static score card and “Continue Learning”.

Why: Demonstrates the full learning-flow loop (browse → learn → quiz → return).

## 7) Games

- `pages/games.dart`:
  - Animated hub with multiple game tiles; Memory Game implemented; others show “coming soon”.
- `pages/memory_game.dart`:
  - Matching pairs with timer, score, win/lose dialogs, and polished visual style.

Why: Adds engagement and rewards alongside learning.

## 8) Backend (Go / Gin)

File: `backend/simple_server.go`

- Endpoints under `/webstudent`:
  - `POST /login` → token and username on success
  - `POST /register` → create user (DB or in-memory) and return token
  - `POST /send_sms_reset` → generate code, store in DB, and (placeholder) send SMS
  - `POST /verify_sms_reset` → validate code and set new password
  - `POST /reset_password` → direct reset without SMS
  - `POST /get_profile` → example profile data
  - `POST /upload_file` → placeholder for uploads

- Storage options:
  - MySQL (preferred in production) or in-memory (development fallback)
  - Passwords hashed via bcrypt
  - JWT generated for sessions
  - CORS open for local Flutter testing

- SMS: `sendSMS` is a placeholder (logs to console); integrate Twilio/AWS SNS for production.

Where: `backend/SETUP_GUIDE.md` describes DB setup and testing.

## 9) Persistence Details (Client)

`StorageService` keys:
- Auth: `auth_token`, `username`, `phone_number`, `is_logged_in`
- Preferences: `learning_path`, `app_language`, `academic_level?`, `tmazight_script?`, `gender`

Used by splash (login), home initialization, profile edits, and selection flow.

## 10) Configuration

- API base URL: `lib/services/api_service.dart` → `baseUrl`
  - For physical devices, replace `localhost` with your machine IP (e.g., `http://192.168.1.10:8005/webstudent`).

- HTTP: Ensure `android/app/src/main/AndroidManifest.xml` has internet permission.

## 11) Build & Run

Backend:
```
cd backend
go run simple_server.go
```

Flutter:
```
flutter pub get
flutter run
```

## 12) Recent Changes Made

- Added `pages/home_tmazight.dart` (6-grade home) and `pages/home_academic.dart` (12-grade home).
- Added `pages/home_router.dart` and wired `/home` to use it (auto-select home by `learning_path`).
- Lightened background tone for all home screens (`home.dart`, `home_tmazight.dart`, `home_academic.dart`).
- Updated `catagory.dart` bottom nav to use named route `/home` for consistency.

## 13) Known Items / Next Steps

- Tamazight/Academic grade cards route to `LevelTopicsPage` as a placeholder; connect to grade-specific content.
- Some UI strings are static; internationalization can be introduced based on `app_language`.
- `sendSMS` is a stub; wire a real provider for production.
- In `home.dart`, a local variable `levelTitle` is computed but not used (harmless warning).

## 14) Route Map

- `/splash` → checks login and routes to `/home` or `/onboarding`
- `/onboarding` → intro slider → `/login`
- `/login` ↔ `/signup` ↔ `/simple-reset` ↔ `/forgot-password`
- `/selection` → save preferences → `/welcome`
- `/welcome` → short delay → `/home`
- `/home` → `HomeRouter` → `HomePage` or `TmazightHomePage` or `AcademicHomePage`
- `/games` → games hub; `/memory-game` → Memory game

## 15) Code Style & Conventions

- Frontend: Flutter/Dart; state kept local to widgets; SharedPreferences for persistence.
- Backend: Go + Gin; JWT for sessions; bcrypt passwords; CORS for dev.
- UI: Consistent modern styling, gradients, shadows, and snackbars for feedback.

---

If you need this documentation exported to PDF or DOCX, open this file in your editor and convert using an extension or print-to-PDF. We can also generate a DOCX on request.


