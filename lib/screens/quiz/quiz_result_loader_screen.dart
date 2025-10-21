import 'package:flutter/material.dart';
import 'package:testproject/services/database_service.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/models/question_model.dart';
import 'package:testproject/screens/quiz/quiz_result_screen.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';

/// Screen to load quiz result data from attemptId
/// This is used when navigating from quiz history
class QuizResultLoaderScreen extends StatefulWidget {
  final String attemptId;
  final String quizId;

  const QuizResultLoaderScreen({
    super.key,
    required this.attemptId,
    required this.quizId,
  });

  @override
  State<QuizResultLoaderScreen> createState() => _QuizResultLoaderScreenState();
}

class _QuizResultLoaderScreenState extends State<QuizResultLoaderScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  QuizAttemptModel? _attempt;
  List<QuestionModel>? _questions;
  List<int>? _userAnswers;

  @override
  void initState() {
    super.initState();
    _loadQuizResultData();
  }

  Future<void> _loadQuizResultData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = DatabaseService();

      // Load attempt data
      final attempt = await dbService.getQuizAttemptById(widget.attemptId);
      if (attempt == null) {
        throw Exception('Quiz attempt not found');
      }

      // Load quiz to get questions
      final quiz = await dbService.getQuiz(widget.quizId);
      if (quiz == null) {
        throw Exception('Quiz not found');
      }

      // Load questions
      final questions = await dbService.getQuizQuestions(widget.quizId);
      if (questions.isEmpty) {
        throw Exception('No questions found for this quiz');
      }

      // Load user answers
      final userAnswersData = await dbService.getUserAnswers(widget.attemptId);

      // Debug: Print loaded answers
      print('===== QUIZ RESULT LOADER DEBUG =====');
      print('Loaded ${userAnswersData.length} answers from database');
      for (var answer in userAnswersData) {
        print(
          'QuestionID: ${answer.questionId}, Selected: ${answer.selectedAnswer}, IsCorrect: ${answer.isCorrect}',
        );
      }

      // Create a map of questionId to selectedAnswer
      final answersMap = <String, int>{};
      for (var answer in userAnswersData) {
        answersMap[answer.questionId] = answer.selectedAnswer;
      }

      // Debug: Print questions
      print('Loaded ${questions.length} questions');
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final userAns = answersMap[q.id] ?? -1;
        print(
          'Q${i + 1} ID:${q.id}, CorrectIndex: ${q.correctAnswerIndex}, UserAnswer: $userAns, Match: ${userAns == q.correctAnswerIndex}',
        );
      }

      // Build userAnswers list in the same order as questions
      // Map each question to its corresponding answer by questionId
      final userAnswers = questions.map((question) {
        return answersMap[question.id] ?? -1; // -1 if not answered
      }).toList();

      print('Final userAnswers list: $userAnswers');
      print('===== END DEBUG =====');

      setState(() {
        _attempt = attempt;
        _questions = questions;
        _userAnswers = userAnswers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz results: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading quiz results...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: ErrorDisplayWidget(
          message: _errorMessage!,
          onRetry: _loadQuizResultData,
        ),
      );
    }

    if (_attempt != null && _questions != null && _userAnswers != null) {
      return QuizResultScreen(
        attempt: _attempt!,
        questions: _questions!,
        userAnswers: _userAnswers!,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: const Center(child: Text('Invalid quiz result data')),
    );
  }
}
