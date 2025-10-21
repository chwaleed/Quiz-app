// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'config/theme.dart';
// import 'config/routes.dart';
// import 'providers/auth_provider.dart';
// import 'providers/quiz_provider.dart';
// import 'providers/leaderboard_provider.dart';
// import 'providers/user_provider.dart';
// import 'firebase_options.dart';

// void main() async {
//   // Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     debugPrint('Firebase initialized successfully');
//   } catch (e) {
//     debugPrint('Firebase initialization error: $e');
//     // Don't throw error, allow app to continue
//   }

//   // Run the app
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Auth Provider - Must be first as other providers may depend on it
//         ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

//         // Quiz Provider - Manages quiz data and quiz taking
//         ChangeNotifierProvider(create: (_) => QuizProvider()),

//         // Leaderboard Provider - Manages leaderboard data
//         ChangeNotifierProvider(create: (_) => LeaderboardProvider()),

//         // User Provider - Manages user profile and quiz history
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: const _AppContent(),
//     );
//   }
// }

// class _AppContent extends StatelessWidget {
//   const _AppContent();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, _) {
//         // Show loading screen while initializing
//         if (!authProvider.isInitialized) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             home: const Scaffold(
//               body: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Initializing...'),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }

//         return MaterialApp(
//           title: 'Quiz Master',
//           debugShowCheckedModeBanner: false,
//           theme: AppTheme.lightTheme,

//           // Always start at login - let login screen handle authenticated users
//           home: const LoginScreenWrapper(),

//           // Use route generator
//           onGenerateRoute: AppRoutes.generateRoute,
//         );
//       },
//     );
//   }
// }

// // Wrapper to handle initial routing based on auth state
// class LoginScreenWrapper extends StatefulWidget {
//   const LoginScreenWrapper({super.key});

//   @override
//   State<LoginScreenWrapper> createState() => _LoginScreenWrapperState();
// }

// class _LoginScreenWrapperState extends State<LoginScreenWrapper> {
//   @override
//   void initState() {
//     super.initState();
//     // Check auth state after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authProvider = context.read<AuthProvider>();
//       if (authProvider.isAuthenticated) {
//         Navigator.of(context).pushReplacementNamed(AppRoutes.home);
//       } else {
//         Navigator.of(context).pushReplacementNamed(AppRoutes.login);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }
