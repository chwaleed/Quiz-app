import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/config/theme.dart';
import 'package:testproject/config/routes.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/providers/auth_provider.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';
import 'package:testproject/models/quiz_model.dart';

/// Admin Dashboard Screen
/// Displays admin statistics and quiz management interface
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load quizzes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizzes(isAdmin: true);
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

    // Check if user is admin
    if (!authProvider.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to access this page',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(context),

          // Statistics cards
          _buildStatisticsCards(),

          // Search bar
          _buildSearchBar(),

          // Quiz list
          Expanded(child: _buildQuizList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateQuiz(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  /// Build gradient header
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage quizzes and view statistics',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards() {
    final quizProvider = context.watch<QuizProvider>();
    final quizzes = quizProvider.quizzes;

    final totalQuizzes = quizzes.length;
    final publishedQuizzes = quizzes.where((q) => q.isActive).length;
    final draftQuizzes = quizzes.where((q) => !q.isActive).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Quizzes',
              totalQuizzes.toString(),
              Icons.quiz,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Published',
              publishedQuizzes.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Drafts',
              draftQuizzes.toString(),
              Icons.drafts,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search quizzes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
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
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
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
        onRetry: () => quizProvider.loadQuizzes(isAdmin: true),
      );
    }
    var quizzes = quizProvider.quizzes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      quizzes = quizzes.where((quiz) {
        return quiz.title.toLowerCase().contains(_searchQuery) ||
            quiz.description.toLowerCase().contains(_searchQuery) ||
            quiz.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (quizzes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.quiz,
        message: _searchQuery.isNotEmpty
            ? 'No quizzes found matching "$_searchQuery"'
            : 'No quizzes yet. Create your first quiz!',
        action: _searchQuery.isEmpty
            ? ElevatedButton.icon(
                onPressed: () => _navigateToCreateQuiz(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Quiz'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await quizProvider.loadQuizzes(isAdmin: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return _buildAdminQuizCard(quiz);
        },
      ),
    );
  }

  /// Build admin quiz card
  Widget _buildAdminQuizCard(QuizModel quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToEditQuiz(context, quiz.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(quiz.isActive),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                quiz.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Category, difficulty, and question count
              Row(
                children: [
                  _buildInfoChip(
                    quiz.category,
                    Icons.category,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    quiz.difficulty,
                    Icons.speed,
                    _getDifficultyColor(quiz.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    '${quiz.totalQuestions} questions',
                    Icons.question_answer,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Submissions button
                  TextButton.icon(
                    onPressed: () => _navigateToSubmissions(context, quiz.id),
                    icon: const Icon(Icons.assignment, size: 18),
                    label: const Text('Submissions'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),

                  // Edit button
                  TextButton.icon(
                    onPressed: () => _navigateToEditQuiz(context, quiz.id),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete button
                  TextButton.icon(
                    onPressed: () => _confirmDeleteQuiz(quiz),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPublished
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPublished
              ? Colors.green.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublished ? Icons.check_circle : Icons.drafts,
            size: 14,
            color: isPublished ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isPublished ? 'Published' : 'Draft',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPublished ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info chip
  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get difficulty color
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Navigate to create quiz screen
  void _navigateToCreateQuiz(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createQuiz);
  }

  /// Navigate to edit quiz screen
  void _navigateToEditQuiz(BuildContext context, String quizId) {
    Navigator.pushNamed(context, AppRoutes.editQuiz, arguments: quizId);
  }

  /// Navigate to quiz submissions screen
  void _navigateToSubmissions(BuildContext context, String quizId) {
    Navigator.pushNamed(context, '/admin/quiz-submissions', arguments: quizId);
  }

  /// Confirm delete quiz
  Future<void> _confirmDeleteQuiz(QuizModel quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteQuiz(quiz);
    }
  }

  /// Delete quiz
  Future<void> _deleteQuiz(QuizModel quiz) async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deleting quiz...')));

      // Delete quiz using provider
      await context.read<QuizProvider>().deleteQuiz(quiz.id);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz "${quiz.title}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
