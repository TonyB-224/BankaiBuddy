# BankaiBuddy

An anime tracker with Firebase-backed auth and per-user Watched / Need to Watch / Favorites lists.

## Setup

### 1. Add Firebase via Swift Package Manager

In Xcode: **File → Add Package Dependencies…**

- URL: `https://github.com/firebase/firebase-ios-sdk`
- Dependency Rule: Up to Next Major Version
- Add these products to the `BankaiBuddy` target:
  - `FirebaseAuth`
  - `FirebaseFirestore`

### 2. Create a Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a project.
2. Add an iOS app with bundle ID `TonyB-224.BankaiBuddy` (matches the existing project).
3. Download `GoogleService-Info.plist`.
4. Drag it into the `BankaiBuddy/` folder in Xcode. Make sure "Copy items if needed" is checked and the `BankaiBuddy` target is selected.

### 3. Enable Email/Password auth

Firebase Console → **Authentication → Sign-in method → Email/Password → Enable**.

### 4. Create a Firestore database

Firebase Console → **Firestore Database → Create database**. Start in **production mode**, then replace the rules with the contents of `firestore.rules` in this folder.

## Architecture

- `BankaiBuddyApp` — configures Firebase, injects `AuthViewModel` and `LibraryStore` into the environment.
- `RootView` — routes between `AuthView` and `MainTabView` based on auth state.
- `AuthViewModel` — wraps `FirebaseAuth`, exposes session state, sign in/up/out, password reset, and friendly error messages.
- `LibraryStore` — listens to per-user Firestore subcollections (`watched`, `watching`, `favorites`), toggles membership.
- `JikanService` — hits the free [Jikan API](https://jikan.moe) for search and top airing. No key required.
- `MainTabView` — four tabs with `.tabBarMinimizeBehavior(.onScrollDown)` so the bar tucks away on scroll.

## Data shape

```
users/{uid}/watched/{malId}    → Anime
users/{uid}/watching/{malId}   → Anime
users/{uid}/favorites/{malId}  → Anime
```

Each `Anime` document stores `id`, `title`, `imageURL`, `synopsis`, `score`, `episodes`, `year`.
