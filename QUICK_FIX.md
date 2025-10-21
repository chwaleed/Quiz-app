# Quick Fix Reference

## Problem

❌ "Unexpected null value" error when running Flutter app

## Solution

✅ Changed `MaterialApp` from using `initialRoute` to `home`

## The Fix

```dart
// In lib/main.dart

// ❌ BEFORE (causes null error)
return MaterialApp(
  initialRoute: authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
  onGenerateRoute: AppRoutes.generateRoute,
);

// ✅ AFTER (works!)
return MaterialApp(
  home: authProvider.isAuthenticated ? const HomeScreen() : const LoginScreen(),
  onGenerateRoute: AppRoutes.generateRoute,
);
```

## Required Imports

```dart
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
```

## Test It

```bash
flutter run
```

App should now start without errors! 🎉
