import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/user_provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Don't throw error, allow app to continue
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - Must be first as other providers may depend on it
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // Initialize asynchronously without blocking
            authProvider.initialize().catchError((error) {
              debugPrint('Auth initialization error: $error');
              return null; // Return null to prevent unhandled errors
            });
            return authProvider;
          },
        ),

        // Quiz Provider - Manages quiz data and quiz taking
        ChangeNotifierProvider(create: (_) => QuizProvider()),

        // Leaderboard Provider - Manages leaderboard data
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),

        // User Provider - Manages user profile and quiz history
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading screen while initializing
          if (!authProvider.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing...'),
                    ],
                  ),
                ),
              ),
            );
          }

          return MaterialApp(
            title: 'Quiz Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,

            // Use home instead of initialRoute for better null safety
            home: authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),

            // Use route generator for navigation
            onGenerateRoute: AppRoutes.generateRoute,

            // Global builder to provide providers to all routes
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
