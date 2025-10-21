import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/config/theme.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/services/database_service.dart';
import 'package:intl/intl.dart';

/// Quiz Submissions Screen for Admin
/// Shows all user submissions for a specific quiz
/// Admin can enable retake for specific users
class QuizSubmissionsScreen extends StatefulWidget {
  final String quizId;

  const QuizSubmissionsScreen({super.key, required this.quizId});

  @override
  State<QuizSubmissionsScreen> createState() => _QuizSubmissionsScreenState();
}

class _QuizSubmissionsScreenState extends State<QuizSubmissionsScreen> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final submissions = await quizProvider.getQuizSubmissions(widget.quizId);

      if (mounted) {
        setState(() {
          _submissions = submissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load submissions: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleRetakePermission(
    String attemptId,
    bool currentValue,
    String userName,
  ) async {
    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      await quizProvider.updateRetakePermission(attemptId, !currentValue);

      // If granting permission, also clear the retake request
      if (!currentValue) {
        final dbService = DatabaseService();
        await dbService.cancelRetakeRequest(attemptId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentValue
                ? '$userName can now retake the quiz'
                : 'Retake permission removed for $userName',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reload submissions
      _loadSubmissions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Submissions'), elevation: 0),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading submissions...')
          : _error != null
          ? ErrorDisplayWidget(message: _error!, onRetry: _loadSubmissions)
          : _submissions.isEmpty
          ? _buildEmptyState()
          : _buildSubmissionsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Submissions Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No users have attempted this quiz',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _submissions.length,
        itemBuilder: (context, index) {
          final submission = _submissions[index];
          final attempt = submission['attempt'] as QuizAttemptModel;
          final userName = submission['userName'] as String;
          final userEmail = submission['userEmail'] as String;
          final fullName = submission['fullName'] as String;

          return _buildSubmissionCard(
            attempt: attempt,
            userName: userName,
            userEmail: userEmail,
            fullName: fullName,
          );
        },
      ),
    );
  }

  Widget _buildSubmissionCard({
    required QuizAttemptModel attempt,
    required String userName,
    required String userEmail,
    required String fullName,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(attempt),
              ],
            ),
            const SizedBox(height: 16),

            // Score Info
            Row(
              children: [
                Expanded(
                  child: _buildScoreItem(
                    'Score',
                    '${attempt.percentage.toStringAsFixed(1)}%',
                    Icons.grade,
                    _getScoreColor(attempt.percentage),
                  ),
                ),
                Expanded(
                  child: _buildScoreItem(
                    'Points',
                    '${attempt.score}',
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildScoreItem(
                    'Grade',
                    attempt.gradeLetter,
                    Icons.school,
                    _getGradeColor(attempt.gradeLetter),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Additional Info
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  '${attempt.correctAnswers}/${attempt.totalQuestions} correct',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 4),
                Text(
                  attempt.formattedTimeTaken,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(attempt.completedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Retake Request Indicator (if requested)
            if (attempt.retakeRequested)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notification_important,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'User has requested a retake',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_downward,
                      color: Colors.orange[700],
                      size: 16,
                    ),
                  ],
                ),
              ),

            // Retake Permission Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: attempt.canRetake
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: attempt.canRetake
                      ? Colors.green.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    attempt.canRetake ? Icons.replay : Icons.block,
                    color: attempt.canRetake ? Colors.green : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attempt.canRetake
                          ? 'User can retake this quiz'
                          : 'User cannot retake (already attempted)',
                      style: TextStyle(
                        fontSize: 13,
                        color: attempt.canRetake
                            ? Colors.green[700]
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: attempt.canRetake,
                    onChanged: (value) {
                      _toggleRetakePermission(
                        attempt.id,
                        attempt.canRetake,
                        userName,
                      );
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(QuizAttemptModel attempt) {
    final isPassed = attempt.isPassed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPassed
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPassed
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isPassed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isPassed ? 'Passed' : 'Failed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPassed ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}
