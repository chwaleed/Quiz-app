import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/config/theme.dart';
import 'package:testproject/config/routes.dart';
import 'package:testproject/core/constants/app_constants.dart';
import 'package:testproject/providers/auth_provider.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/widgets/quiz_card.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';
import 'package:testproject/screens/profile/profile_screen.dart';
import 'package:testproject/screens/leaderboard/leaderboard_screen.dart';
import 'package:testproject/screens/admin/admin_dashboard_screen.dart';

/// Home screen with quiz listing, search, filters, and bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    // Load quizzes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizzes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Bottom navigation pages
    final pages = [
      _buildQuizListPage(), // Home/Quiz List
      const LeaderboardScreen(), // Leaderboard Screen (Session 9)
      const ProfileScreen(), // Profile Screen (Session 8)
      if (authProvider.isAdmin)
        const AdminDashboardScreen(), // Admin Dashboard (Session 10)
    ];

    return Scaffold(
      appBar: _buildAppBar(authProvider),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(authProvider),
    );
  }

  /// Build app bar with search
  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      title: const Text(AppConstants.appName),
      actions: [
        // Logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _handleLogout(authProvider),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar(AuthProvider authProvider) {
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard),
        label: 'Leaderboard',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      if (authProvider.isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
    );
  }

  /// Build quiz list page (main home view)
  Widget _buildQuizListPage() {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Filter chips
        _buildFilterChips(),

        // Quiz list
        Expanded(child: _buildQuizList()),
      ],
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search quizzes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<QuizProvider>().clearFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<QuizProvider>().clearFilters();
          } else {
            context.read<QuizProvider>().searchQuizzes(value);
          }
        },
      ),
    );
  }

  /// Build filter chips (category and difficulty)
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Category filter
            _buildCategoryFilter(),
            const SizedBox(width: 8),

            // Difficulty filter
            _buildDifficultyFilter(),

            const SizedBox(width: 8),

            // Clear filters button
            if (_selectedCategory != null || _selectedDifficulty != null)
              ActionChip(
                label: const Text('Clear Filters'),
                onPressed: _clearFilters,
                avatar: const Icon(Icons.clear, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  /// Build category filter dropdown
  Widget _buildCategoryFilter() {
    return PopupMenuButton<String>(
      child: Chip(
        label: Text(
          _selectedCategory ?? 'All Categories',
          style: TextStyle(
            color: _selectedCategory != null
                ? AppTheme.primaryColor
                : Colors.grey[700],
          ),
        ),
        avatar: Icon(
          Icons.category,
          size: 18,
          color: _selectedCategory != null
              ? AppTheme.primaryColor
              : Colors.grey[700],
        ),
        backgroundColor: _selectedCategory != null
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey[200],
      ),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(value: 'all', child: Text('All Categories')),
          ...AppConstants.defaultCategories.map((category) {
            return PopupMenuItem(value: category, child: Text(category));
          }),
        ];
      },
      onSelected: (value) {
        setState(() => _selectedCategory = value == 'all' ? null : value);
        context.read<QuizProvider>().filterByCategory(
          value == 'all' ? null : value,
        );
      },
    );
  }

  /// Build difficulty filter chips
  Widget _buildDifficultyFilter() {
    return PopupMenuButton<String>(
      child: Chip(
        label: Text(
          _selectedDifficulty ?? 'All Levels',
          style: TextStyle(
            color: _selectedDifficulty != null
                ? AppTheme.primaryColor
                : Colors.grey[700],
          ),
        ),
        avatar: Icon(
          Icons.speed,
          size: 18,
          color: _selectedDifficulty != null
              ? AppTheme.primaryColor
              : Colors.grey[700],
        ),
        backgroundColor: _selectedDifficulty != null
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey[200],
      ),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(value: 'all', child: Text('All Levels')),
          ...AppConstants.difficultyLevels.map((difficulty) {
            return PopupMenuItem(value: difficulty, child: Text(difficulty));
          }),
        ];
      },
      onSelected: (value) {
        setState(() => _selectedDifficulty = value == 'all' ? null : value);
        context.read<QuizProvider>().filterByDifficulty(
          value == 'all' ? null : value,
        );
      },
    );
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
    });
    context.read<QuizProvider>().clearFilters();
  }

  /// Build quiz list
  Widget _buildQuizList() {
    final quizProvider = context.watch<QuizProvider>();

    if (quizProvider.isLoadingQuizzes) {
      return const LoadingWidget(message: 'Loading quizzes...');
    }

    if (quizProvider.quizzesError != null) {
      return ErrorDisplayWidget(
        message: quizProvider.quizzesError!,
        onRetry: () => quizProvider.loadQuizzes(),
      );
    }

    final quizzes = quizProvider.quizzes;

    if (quizzes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.quiz,
        message:
            quizProvider.searchQuery.isNotEmpty ||
                _selectedCategory != null ||
                _selectedDifficulty != null
            ? 'No quizzes found matching your criteria'
            : 'No quizzes available yet',
        action: ElevatedButton.icon(
          onPressed: () => quizProvider.loadQuizzes(),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await quizProvider.loadQuizzes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          final userId = context.read<AuthProvider>().currentUser?.uid;

          return FutureBuilder<Map<String, dynamic>>(
            future: _getQuizAttemptStatus(quiz.id, userId),
            builder: (context, snapshot) {
              final bestScore = snapshot.data?['bestScore'] as double?;
              final hasAttempted =
                  snapshot.data?['hasAttempted'] as bool? ?? false;

              return QuizCard(
                quiz: quiz,
                bestScore: bestScore,
                hasAttempted: hasAttempted,
                onTap: () => _navigateToQuizDetail(quiz.id),
              );
            },
          );
        },
      ),
    );
  }

  /// Get quiz attempt status for user
  Future<Map<String, dynamic>> _getQuizAttemptStatus(
    String quizId,
    String? userId,
  ) async {
    if (userId == null) {
      return {'bestScore': null, 'hasAttempted': false};
    }

    final quizProvider = context.read<QuizProvider>();
    final bestAttempt = await quizProvider.getUserBestAttempt(userId, quizId);
    final hasAttempted = await quizProvider.hasUserAttemptedQuiz(
      userId,
      quizId,
    );

    return {'bestScore': bestAttempt?.percentage, 'hasAttempted': hasAttempted};
  }

  /// Navigate to quiz detail screen
  void _navigateToQuizDetail(String quizId) {
    Navigator.pushNamed(context, AppRoutes.quizDetail, arguments: quizId);
  }

  /// Handle logout
  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(AppConstants.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.buttonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppConstants.buttonLogout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }
}
