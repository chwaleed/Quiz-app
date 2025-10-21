import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/config/theme.dart';
import 'package:testproject/providers/quiz_provider.dart';
import 'package:testproject/models/quiz_model.dart';
import 'package:testproject/models/question_model.dart';
import 'package:testproject/widgets/question_builder.dart';
import 'package:testproject/core/widgets/loading_widget.dart';
import 'package:testproject/core/widgets/error_widget.dart';

/// Edit Quiz Screen
/// Allows admins to edit existing quizzes
class EditQuizScreen extends StatefulWidget {
  final String quizId;

  const EditQuizScreen({super.key, required this.quizId});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _passingScoreController = TextEditingController();

  String _selectedDifficulty = 'Easy';
  bool _hasTimeLimit = false;
  bool _isActive = false;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _error;

  List<QuestionModel> _questions = [];
  QuizModel? _originalQuiz;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _categories = [
    'Programming',
    'Mathematics',
    'Science',
    'History',
    'Geography',
    'Literature',
    'General Knowledge',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _timeLimitController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  /// Load quiz and questions data
  Future<void> _loadQuizData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quizProvider = context.read<QuizProvider>();

      // Load quiz details and questions
      await quizProvider.loadQuizDetail(widget.quizId);

      final quiz = quizProvider.currentQuiz;
      final questions = quizProvider.currentQuestions;

      if (quiz == null) {
        throw Exception('Quiz not found');
      }

      // Populate form fields
      _originalQuiz = quiz;
      _titleController.text = quiz.title;
      _descriptionController.text = quiz.description;
      _categoryController.text = quiz.category;
      _selectedDifficulty = quiz.difficulty;
      _passingScoreController.text = quiz.passingScore.toString();
      _hasTimeLimit = quiz.hasTimeLimit;
      if (_hasTimeLimit) {
        _timeLimitController.text = (quiz.timeLimit ~/ 60).toString();
      }
      _isActive = quiz.isActive;
      _questions = List.from(questions);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Quiz'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const LoadingWidget(message: 'Loading quiz data...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Quiz'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: ErrorDisplayWidget(message: _error!, onRetry: _loadQuizData),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quiz Information Section
            _buildSectionTitle('Quiz Information'),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'Enter quiz title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter quiz description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value:
                  _categoryController.text.isNotEmpty &&
                      _categories.contains(_categoryController.text)
                  ? _categoryController.text
                  : _categories.first,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                _categoryController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                prefixIcon: Icon(Icons.speed),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDifficulty = value ?? 'Easy');
              },
            ),
            const SizedBox(height: 24),

            // Settings Section
            _buildSectionTitle('Quiz Settings'),
            const SizedBox(height: 16),

            // Passing Score
            TextFormField(
              controller: _passingScoreController,
              decoration: const InputDecoration(
                labelText: 'Passing Score (%) *',
                hintText: 'Enter passing percentage',
                prefixIcon: Icon(Icons.check_circle),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Passing score is required';
                }
                final score = int.tryParse(value);
                if (score == null || score < 0 || score > 100) {
                  return 'Enter a valid percentage (0-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Time Limit Toggle
            SwitchListTile(
              title: const Text('Has Time Limit'),
              subtitle: const Text('Enable time limit for this quiz'),
              value: _hasTimeLimit,
              onChanged: (value) {
                setState(() => _hasTimeLimit = value);
              },
            ),

            // Time Limit Input
            if (_hasTimeLimit) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (minutes) *',
                  hintText: 'Enter time limit',
                  prefixIcon: Icon(Icons.timer),
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
                validator: _hasTimeLimit
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Time limit is required';
                        }
                        final minutes = int.tryParse(value);
                        if (minutes == null || minutes < 1) {
                          return 'Enter a valid time limit (min 1 minute)';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
            const SizedBox(height: 16),

            // Publish Toggle
            SwitchListTile(
              title: const Text('Publish Quiz'),
              subtitle: const Text('Make quiz visible to users'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 24),

            // Questions Section
            _buildSectionTitle('Questions (${_questions.length})'),
            const SizedBox(height: 8),
            Text(
              'Minimum 5 questions required',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Questions List
            if (_questions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No questions yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first question to get started',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return _buildQuestionCard(question, index);
              }).toList(),

            const SizedBox(height: 16),

            // Add Question Button
            OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  /// Build question card
  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  radius: 16,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editQuestion(index),
                  color: AppTheme.primaryColor,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteQuestion(index),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Correct Answer: ${question.options[question.correctAnswerIndex]}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Points: ${question.points}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Add new question
  void _addQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionBuilderWidget(
        onSave: (question) {
          setState(() {
            _questions.add(
              question.copyWith(
                order: _questions.length + 1,
                quizId: widget.quizId,
              ),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Edit existing question
  void _editQuestion(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionBuilderWidget(
        question: _questions[index],
        onSave: (question) {
          setState(() {
            _questions[index] = question.copyWith(
              order: index + 1,
              quizId: widget.quizId,
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Delete question
  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _questions.removeAt(index);
                // Reorder remaining questions
                for (int i = 0; i < _questions.length; i++) {
                  _questions[i] = _questions[i].copyWith(order: i + 1);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Save quiz
  Future<void> _saveQuiz() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate minimum questions
    if (_questions.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 5 questions required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final quizProvider = context.read<QuizProvider>();

      // Calculate total points
      final totalPoints = _questions.fold(
        0,
        (sum, question) => sum + question.points,
      );

      // Update quiz model
      final updatedQuiz = _originalQuiz!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : _categories.first,
        difficulty: _selectedDifficulty,
        timeLimit: _hasTimeLimit
            ? int.parse(_timeLimitController.text) * 60
            : 0, // Convert to seconds
        passingScore: int.parse(_passingScoreController.text),
        totalQuestions: _questions.length,
        totalPoints: totalPoints,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      // Save quiz with questions
      await quizProvider.updateQuizWithQuestions(updatedQuiz, _questions);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
