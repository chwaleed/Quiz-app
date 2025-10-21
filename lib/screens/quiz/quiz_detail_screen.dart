import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/quiz_model.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/providers/auth_provider.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';
import 'package:testproject/core/widgets/custom_button.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  QuizAttemptModel? _bestAttempt;
  bool _hasAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizDetails();
    });
  }

  Future<void> _loadQuizDetails() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await quizProvider.loadQuizDetail(widget.quizId);

    if (success && authProvider.currentUser != null) {
      // Load user's best attempt for this quiz
      _bestAttempt = await quizProvider.getUserBestAttempt(
        authProvider.currentUser!.uid,
        widget.quizId,
      );

      // Check if user has attempted (without retake permission)
      _hasAttempted = await quizProvider.hasUserAttemptedQuiz(
        authProvider.currentUser!.uid,
        widget.quizId,
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _startQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to take the quiz')),
      );
      return;
    }

    // Start the quiz
    final started = quizProvider.startQuiz();

    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to start quiz')));
    } else {
      // Navigate to quiz taking screen
      Navigator.pushNamed(context, '/quiz-taking', arguments: widget.quizId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Details'), elevation: 0),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoadingQuizDetail) {
            return const LoadingWidget(message: 'Loading quiz details...');
          }

          if (quizProvider.quizDetailError != null) {
            return ErrorDisplayWidget(
              message: quizProvider.quizDetailError!,
              onRetry: _loadQuizDetails,
            );
          }

          final quiz = quizProvider.currentQuiz;

          if (quiz == null) {
            return const ErrorDisplayWidget(message: 'Quiz not found');
          }

          return _buildQuizDetails(quiz);
        },
      ),
    );
  }

  Widget _buildQuizDetails(QuizModel quiz) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Quiz Info Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.category,
                        label: 'Category',
                        value: quiz.category,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.speed,
                        label: 'Difficulty',
                        value: quiz.difficulty,
                        color: _getDifficultyColor(quiz.difficulty),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.quiz,
                        label: 'Questions',
                        value: '${quiz.totalQuestions}',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.timer,
                        label: 'Time Limit',
                        value: quiz.formattedTimeLimit,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.stars,
                        label: 'Total Points',
                        value: '${quiz.totalPoints}',
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.check_circle,
                        label: 'Pass Score',
                        value: '${quiz.passingScore}%',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Attempts Section
                if (_bestAttempt != null)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Best Score',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildScoreItem(
                                'Score',
                                '${_bestAttempt!.percentage.toStringAsFixed(1)}%',
                              ),
                              _buildScoreItem(
                                'Grade',
                                _bestAttempt!.gradeLetter,
                              ),
                              _buildScoreItem(
                                'Points',
                                '${_bestAttempt!.score}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Rules Section
                Text(
                  'Quiz Rules',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  '📝 Answer all ${quiz.totalQuestions} questions',
                ),
                _buildRuleItem('⏱️ Complete within ${quiz.formattedTimeLimit}'),
                _buildRuleItem(
                  '✅ Score ${quiz.passingScore}% or higher to pass',
                ),
                _buildRuleItem('🎯 Each question has only one correct answer'),
                _buildRuleItem(
                  '📊 You can review your answers after submission',
                ),
                _buildRuleItem(
                  '🔄 You can retake the quiz to improve your score',
                ),

                const SizedBox(height: 32),

                // Start Button
                SizedBox(
                  width: double.infinity,
                  child: _hasAttempted
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Already Attempted',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have already attempted this quiz. Contact admin for retake permission.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : CustomButton(
                          text: 'Start Quiz',
                          onPressed: _startQuiz,
                          icon: Icons.play_arrow,
                        ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(rule, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

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
}
