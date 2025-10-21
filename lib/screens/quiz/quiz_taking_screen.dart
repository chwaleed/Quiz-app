import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/providers/auth_provider.dart';
import 'package:testproject/widgets/question_card.dart';

class QuizTakingScreen extends StatefulWidget {
  final String quizId;

  const QuizTakingScreen({super.key, required this.quizId});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taking Quiz'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _onBackPressed(context),
          ),
          actions: [
            Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.currentQuiz?.hasTimeLimit ?? false) {
                  return _buildTimerWidget(quizProvider);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (!quizProvider.isQuizActive) {
              return const Center(child: Text('Quiz not active'));
            }

            final currentQuestion = quizProvider.currentQuestion;

            if (currentQuestion == null) {
              return const Center(child: Text('No questions available'));
            }

            return Column(
              children: [
                // Progress Bar
                _buildProgressBar(quizProvider),

                // Question Counter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.totalQuestions}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${quizProvider.answeredQuestionsCount} answered',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Question Card
                Expanded(
                  child: SingleChildScrollView(
                    child: QuestionCard(
                      question: currentQuestion,
                      selectedAnswer: quizProvider.getSelectedAnswer(
                        quizProvider.currentQuestionIndex,
                      ),
                      onAnswerSelected: (index) {
                        quizProvider.selectAnswer(index);
                      },
                    ),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(quizProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(QuizProvider quizProvider) {
    return LinearProgressIndicator(
      value:
          (quizProvider.currentQuestionIndex + 1) / quizProvider.totalQuestions,
      minHeight: 6,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildTimerWidget(QuizProvider quizProvider) {
    final timeRemaining = quizProvider.timeRemaining;
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final isLowTime = timeRemaining < 60; // Less than 1 minute

    // Auto-submit when time runs out
    if (timeRemaining == 0 && !_isSubmitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _submitQuiz(context, autoSubmit: true);
      });
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 20,
            color: isLowTime ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isLowTime ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(QuizProvider quizProvider) {
    final canGoPrevious = quizProvider.currentQuestionIndex > 0;
    final canGoNext =
        quizProvider.currentQuestionIndex < quizProvider.totalQuestions - 1;
    final isLastQuestion =
        quizProvider.currentQuestionIndex == quizProvider.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (canGoPrevious)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  quizProvider.previousQuestion();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          if (canGoPrevious && (canGoNext || isLastQuestion))
            const SizedBox(width: 12),

          // Next or Submit Button
          if (canGoNext)
            Expanded(
              flex: canGoPrevious ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  quizProvider.nextQuestion();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          if (isLastQuestion)
            Expanded(
              flex: canGoPrevious ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _showSubmitConfirmation(context, quizProvider),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showSubmitConfirmation(
    BuildContext context,
    QuizProvider quizProvider,
  ) async {
    final unanswered =
        quizProvider.totalQuestions - quizProvider.answeredQuestionsCount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered question(s). Are you sure you want to submit?'
              : 'Are you sure you want to submit your answers?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _submitQuiz(context);
    }
  }

  Future<void> _submitQuiz(
    BuildContext context, {
    bool autoSubmit = false,
  }) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      // IMPORTANT: Get answers BEFORE submitting (submitQuiz clears the answers!)
      final answersList = List.generate(
        quizProvider.totalQuestions,
        (index) => quizProvider.getSelectedAnswer(index) ?? -1,
      );

      final attempt = await quizProvider.submitQuiz(
        authProvider.currentUser!.uid,
      );

      if (!mounted) return;

      if (attempt != null) {
        // DEBUG: Print what we're passing to result screen

        print('===== QUIZ SUBMISSION DEBUG =====');
        print('Total questions: ${quizProvider.totalQuestions}');
        print('Answers collected BEFORE submit: $answersList');
        for (var i = 0; i < quizProvider.currentQuestions.length; i++) {
          final q = quizProvider.currentQuestions[i];
          final ans = answersList[i];
          print(
            'Q${i + 1}: CorrectIndex=${q.correctAnswerIndex}, UserAnswer=$ans, Match=${ans == q.correctAnswerIndex}',
          );
        }
        print('===== END DEBUG =====');

        // Navigate to result screen
        Navigator.pushReplacementNamed(
          context,
          '/quiz-result',
          arguments: {
            'attempt': attempt,
            'questions': quizProvider.currentQuestions,
            'answers': answersList,
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to submit quiz')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    if (!quizProvider.isQuizActive) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      quizProvider.exitQuiz();
      return true;
    }

    return false;
  }
}
