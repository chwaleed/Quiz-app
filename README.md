# 🎯 Quiz Master - Flutter Quiz Application

A complete quiz application built with Flutter featuring user authentication, role-based access control, quiz management, leaderboards, and comprehensive admin capabilities.

## 📱 Features

### For Users

- ✅ **Authentication** - Secure sign up and login
- ✅ **Quiz Taking** - Interactive quiz experience with timer
- ✅ **Results & Analytics** - Detailed score breakdown and explanations
- ✅ **Profile Management** - Track stats, view history
- ✅ **Leaderboard** - Compete with other users globally
- ✅ **Multiple Categories** - Various quiz topics
- ✅ **Difficulty Levels** - Easy, Medium, and Hard

### For Admins

- ✅ **Quiz Creation** - Build quizzes with rich question types
- ✅ **Quiz Management** - Edit, delete, and manage quizzes
- ✅ **User Management** - View user statistics
- ✅ **Dashboard** - Admin analytics and insights

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x+
- **Language**: Dart
- **State Management**: Provider
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Storage
- **Architecture**: Clean Architecture / MVVM

## 📁 Project Structure

```
lib/
├── config/              # App configuration
│   ├── theme.dart       # Theme configuration
│   └── routes.dart      # Route definitions
├── core/                # Core utilities
│   ├── constants/       # App constants
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable widgets
├── models/              # Data models
├── services/            # Backend services
├── providers/           # State management
├── screens/             # UI screens
│   ├── auth/           # Authentication screens
│   ├── home/           # Home screen
│   ├── quiz/           # Quiz screens
│   ├── profile/        # Profile screens
│   ├── leaderboard/    # Leaderboard
│   └── admin/          # Admin screens
└── widgets/             # Feature widgets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd testproject
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a Firebase project
   - Add Android/iOS apps
   - Download config files:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Enable Storage

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Development Progress

Current Status: **Session 1 Complete** ✅

See [PROGRESS.md](PROGRESS.md) for detailed progress tracking.
See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for complete development plan.

### Completed Sessions

- ✅ **Session 1**: Project Setup & Foundation

### Upcoming Sessions

- ⏳ Session 2: Data Models & Constants
- ⏳ Session 3: Firebase Services
- ⏳ Session 4: State Management
- And more...

## 📚 Documentation

- [Implementation Plan](IMPLEMENTATION_PLAN.md) - Complete step-by-step guide
- [Project Description](projectDescription.md) - Full specification
- [Progress Tracker](PROGRESS.md) - Current progress and status
- [Session 1 Summary](SESSION_1_SUMMARY.md) - Session 1 completion notes

## 🎨 Design

### Color Scheme

- Primary: Blue (#2196F3)
- Secondary: Deep Purple (#673AB7)
- Success: Green (#4CAF50)
- Error: Red (#F44336)
- Warning: Orange (#FF9800)

### Difficulty Colors

- Easy: Green
- Medium: Orange
- Hard: Red

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/validators_test.dart
```

## 📦 Dependencies

### Main Dependencies

```yaml
dependencies:
  provider: ^6.1.0 # State management
  firebase_core: ^3.6.0 # Firebase core
  firebase_auth: ^5.3.1 # Authentication
  cloud_firestore: ^5.4.4 # Database
  firebase_storage: ^12.3.2 # File storage
  cached_network_image: ^3.4.1 # Image caching
  image_picker: ^1.1.2 # Image selection
  flutter_secure_storage: ^9.2.2 # Secure storage
  shared_preferences: ^2.3.2 # Local storage
  intl: ^0.19.0 # Internationalization
```

## 🏗️ Build & Release

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## 🤝 Contributing

This is a learning project. Contributions, issues, and feature requests are welcome!

## 📄 License

This project is for educational purposes.

## 👨‍💻 Development

### Code Style

- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Keep functions small and focused

### Commit Messages

- Use clear, descriptive commit messages
- Format: `[Session X] Description of changes`
- Example: `[Session 1] Set up project structure and dependencies`

## 📞 Support

For questions or issues:

- Check the [Implementation Plan](IMPLEMENTATION_PLAN.md)
- Review [Session Summaries](SESSION_1_SUMMARY.md)
- Check Flutter documentation

## 🎯 Roadmap

- [x] Session 1: Foundation ✅
- [ ] Session 2: Data Models
- [ ] Session 3: Firebase Integration
- [ ] Session 4: State Management
- [ ] Session 5: Authentication UI
- [ ] Session 6: Quiz Browsing
- [ ] Session 7: Quiz Taking
- [ ] Session 8: User Profile
- [ ] Session 9: Leaderboard
- [ ] Session 10: Admin Panel
- [ ] Session 11: UI Polish
- [ ] Session 12: Testing
- [ ] Session 13: Deployment

## ⭐ Features Coming Soon

- Push notifications
- Offline support
- Social sharing
- Quiz recommendations
- Dark mode
- Multi-language support
- Achievement badges
- Quiz certificates

---

**Built with ❤️ using Flutter**

_Last Updated: October 18, 2025_
