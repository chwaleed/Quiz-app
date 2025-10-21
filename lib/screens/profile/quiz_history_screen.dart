import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/auth_provider.dart';
import 'package:testproject/providers/user_provider.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/models/quiz_model.dart';
import 'package:testproject/widgets/history_tile.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await userProvider.loadQuizHistory(authProvider.currentUser!.uid);

      // Load quiz details for all attempts
      await quizProvider.loadQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz History')),
        body: const Center(
          child: Text('Please log in to view your quiz history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        actions: [
          // Filter Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              if (value == 'clear') {
                userProvider.clearHistoryFilters();
              } else {
                userProvider.filterHistory(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color:
                          userProvider.historyFilter == null ||
                              userProvider.historyFilter == 'all'
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('All Attempts'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'passed',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: userProvider.historyFilter == 'passed'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('Passed Only'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'failed',
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: userProvider.historyFilter == 'failed'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('Failed Only'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Clear Filter'),
                  ],
                ),
              ),
            ],
          ),

          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              userProvider.sortHistory(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color:
                          userProvider.historySortBy == 'date' ||
                              userProvider.historySortBy == null
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('By Date (Newest)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'score',
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: userProvider.historySortBy == 'score'
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('By Score (Highest)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'quiz',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: userProvider.historySortBy == 'quiz'
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Text('By Quiz Name'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _buildBody(userProvider, quizProvider),
      ),
    );
  }

  Widget _buildBody(UserProvider userProvider, QuizProvider quizProvider) {
    // Loading state
    if (userProvider.isLoadingHistory) {
      return const LoadingWidget(message: 'Loading quiz history...');
    }

    // Error state
    if (userProvider.historyError != null) {
      return ErrorDisplayWidget(
        message: userProvider.historyError!,
        onRetry: _loadHistory,
      );
    }

    // Empty state
    if (userProvider.quizHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Quiz History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take your first quiz to see it here!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.quiz),
              label: const Text('Browse Quizzes'),
            ),
          ],
        ),
      );
    }

    // Success state with data
    final history = userProvider.quizHistory;

    return Column(
      children: [
        // Filter indicator
        if (userProvider.historyFilter != null &&
            userProvider.historyFilter != 'all')
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Showing ${userProvider.historyFilter} attempts',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    userProvider.clearHistoryFilters();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

        // Results count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${history.length} ${history.length == 1 ? 'attempt' : 'attempts'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final attempt = history[index];
              // Find quiz from loaded quizzes
              final quiz = quizProvider.quizzes.firstWhere(
                (q) => q.id == attempt.quizId,
                orElse: () => QuizModel(
                  id: attempt.quizId,
                  title: 'Unknown Quiz',
                  description: '',
                  category: '',
                  difficulty: '',
                  timeLimit: 0,
                  passingScore: 0,
                  totalQuestions: attempt.totalQuestions,
                  totalPoints: 0,
                  createdBy: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              return HistoryTile(
                attempt: attempt,
                quiz: quiz,
                onTap: () {
                  // Navigate to quiz result screen
                  Navigator.pushNamed(
                    context,
                    '/quiz-result',
                    arguments: {
                      'quizId': attempt.quizId,
                      'attemptId': attempt.id,
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
