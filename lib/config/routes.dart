import 'package:flutter/material.dart';
import 'package:testproject/screens/auth/login_screen.dart';
import 'package:testproject/screens/auth/signup_screen.dart';
import 'package:testproject/screens/auth/forgot_password_screen.dart';
import 'package:testproject/screens/home/home_screen.dart';
import 'package:testproject/screens/quiz/quiz_detail_screen.dart';
import 'package:testproject/screens/quiz/quiz_taking_screen.dart';
import 'package:testproject/screens/quiz/quiz_result_screen.dart';
import 'package:testproject/screens/quiz/quiz_result_loader_screen.dart';
import 'package:testproject/screens/profile/profile_screen.dart';
import 'package:testproject/screens/profile/quiz_history_screen.dart';
import 'package:testproject/screens/profile/edit_profile_screen.dart';
import 'package:testproject/screens/leaderboard/leaderboard_screen.dart';
import 'package:testproject/screens/admin/admin_dashboard_screen.dart';
import 'package:testproject/screens/admin/create_quiz_screen.dart';
import 'package:testproject/screens/admin/edit_quiz_screen.dart';
import 'package:testproject/screens/admin/quiz_submissions_screen.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/models/question_model.dart';

/// App route names
class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/home';
  static const String quizDetail = '/quiz-detail';
  static const String quizTaking = '/quiz-taking';
  static const String quizResult = '/quiz-result';

  // Profile Routes
  static const String profile = '/profile';
  static const String quizHistory = '/quiz-history';
  static const String editProfile = '/edit-profile';

  // Leaderboard Routes
  static const String leaderboard = '/leaderboard';

  // Admin Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String createQuiz = '/create-quiz';
  static const String editQuiz = '/edit-quiz';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Home Route
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Quiz Routes
      case quizDetail:
        final quizId = settings.arguments as String?;
        if (quizId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Quiz ID is required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizDetailScreen(quizId: quizId),
        );

      case quizTaking:
        final quizId = settings.arguments as String?;
        if (quizId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Quiz ID is required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizTakingScreen(quizId: quizId),
        );

      case quizResult:
        final args = settings.arguments as Map<String, dynamic>?;

        // Handle direct navigation with attempt, questions, and answers
        if (args != null &&
            args['attempt'] != null &&
            args['questions'] != null &&
            args['answers'] != null) {
          return MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              attempt: args['attempt'] as QuizAttemptModel,
              questions: args['questions'] as List<QuestionModel>,
              userAnswers: args['answers'] as List<int>,
            ),
          );
        }

        // Handle navigation from quiz history with attemptId
        if (args != null && args['attemptId'] != null) {
          return MaterialPageRoute(
            builder: (_) => QuizResultLoaderScreen(
              attemptId: args['attemptId'] as String,
              quizId: args['quizId'] as String,
            ),
          );
        }

        // Invalid arguments
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid quiz result data')),
          ),
        );

      // Profile Routes
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case quizHistory:
        return MaterialPageRoute(builder: (_) => const QuizHistoryScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // Leaderboard Route
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());

      // Admin Routes
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case createQuiz:
        return MaterialPageRoute(builder: (_) => const CreateQuizScreen());

      case editQuiz:
        final quizId = settings.arguments as String?;
        if (quizId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Quiz ID is required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => EditQuizScreen(quizId: quizId),
        );

      case '/admin/quiz-submissions':
        final quizId = settings.arguments as String?;
        if (quizId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Quiz ID is required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizSubmissionsScreen(quizId: quizId),
        );

      // Default
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
