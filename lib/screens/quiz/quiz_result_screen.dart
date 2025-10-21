import 'package:flutter/material.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/models/question_model.dart';
import 'package:testproject/widgets/question_card.dart';
import 'package:testproject/core/widgets/custom_button.dart';
import 'package:testproject/services/database_service.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptModel attempt;
  final List<QuestionModel> questions;
  final List<int> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.attempt,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Result Header
            _buildResultHeader(context),

            // Statistics Cards
            _buildStatisticsSection(context),

            const SizedBox(height: 24),

            // Detailed Review Section
            _buildReviewSection(context),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    final isPassed = attempt.isPassed;
    final headerColor = isPassed ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor.shade400, headerColor.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? 'Congratulations!' : 'Keep Trying!',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPassed ? 'You passed the quiz!' : 'You didn\'t pass this time',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${attempt.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Grade: ${attempt.gradeLetter}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Correct',
                  value: '${attempt.correctAnswers}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cancel,
                  label: 'Incorrect',
                  value: '${attempt.totalQuestions - attempt.correctAnswers}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.stars,
                  label: 'Score',
                  value: '${attempt.score} pts',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  label: 'Time Taken',
                  value: _formatTime(attempt.timeTaken),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Performance: ${attempt.performanceRating}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Answer Review',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          questions.length,
          (index) => _buildQuestionReview(context, index),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(BuildContext context, int index) {
    final question = questions[index];
    final userAnswer = userAnswers[index];
    final isCorrect = userAnswer == question.correctAnswerIndex;

    // DEBUG: Print comparison
    print(
      'Question ${index + 1}: userAnswer=$userAnswer, correctAnswer=${question.correctAnswerIndex}, isCorrect=$isCorrect',
    );

    return Column(
      children: [
        // Question Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                '${question.points} pts',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Question Card with Review Mode
        QuestionCard(
          question: question,
          selectedAnswer: userAnswer,
          onAnswerSelected: (_) {}, // Read-only in review mode
          isReview: true,
          correctAnswer: question.correctAnswerIndex,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Request Retake Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Request Retake',
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Request Retake'),
                    content: const Text(
                      'Do you want to request permission to retake this quiz? '
                      'An admin will review your request.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Request'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    // Request retake
                    final dbService = DatabaseService();
                    await dbService.requestRetake(attempt.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Retake request submitted! '
                            'An admin will review it shortly.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate back to home
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to request retake: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              icon: Icons.refresh,
            ),
          ),
          const SizedBox(height: 12),

          // Back to Home Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Pop all quiz screens and return to home
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
