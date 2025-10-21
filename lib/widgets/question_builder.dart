import 'package:flutter/material.dart';
import 'package:testproject/config/theme.dart';
import 'package:testproject/models/question_model.dart';

/// Question Builder Widget
/// Modal bottom sheet for adding/editing questions
class QuestionBuilderWidget extends StatefulWidget {
  final QuestionModel? question; // null for new question
  final Function(QuestionModel) onSave;

  const QuestionBuilderWidget({super.key, this.question, required this.onSave});

  @override
  State<QuestionBuilderWidget> createState() => _QuestionBuilderWidgetState();
}

class _QuestionBuilderWidgetState extends State<QuestionBuilderWidget> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');

  int _correctAnswerIndex = 0;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      // Load existing question data
      _questionController.text = widget.question!.questionText;
      _option1Controller.text = widget.question!.options[0];
      _option2Controller.text = widget.question!.options[1];
      _option3Controller.text = widget.question!.options[2];
      _option4Controller.text = widget.question!.options[3];
      _correctAnswerIndex = widget.question!.correctAnswerIndex;
      _explanationController.text = widget.question!.explanation ?? '';
      _pointsController.text = widget.question!.points.toString();
      _imageUrl = widget.question!.questionImageUrl;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Icon(
                      widget.question == null ? Icons.add : Icons.edit,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.question == null
                          ? 'Add Question'
                          : 'Edit Question',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Text
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question Text *',
                    hintText: 'Enter your question',
                    prefixIcon: Icon(Icons.question_answer),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question text is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Question must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Options Section
                const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Option 1
                _buildOptionField(
                  controller: _option1Controller,
                  label: 'Option 1 *',
                  index: 0,
                ),
                const SizedBox(height: 12),

                // Option 2
                _buildOptionField(
                  controller: _option2Controller,
                  label: 'Option 2 *',
                  index: 1,
                ),
                const SizedBox(height: 12),

                // Option 3
                _buildOptionField(
                  controller: _option3Controller,
                  label: 'Option 3 *',
                  index: 2,
                ),
                const SizedBox(height: 12),

                // Option 4
                _buildOptionField(
                  controller: _option4Controller,
                  label: 'Option 4 *',
                  index: 3,
                ),
                const SizedBox(height: 24),

                // Correct Answer Selector
                const Text(
                  'Correct Answer *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (index) {
                  return RadioListTile<int>(
                    title: Text('Option ${index + 1}'),
                    value: index,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() => _correctAnswerIndex = value ?? 0);
                    },
                    activeColor: AppTheme.primaryColor,
                  );
                }),
                const SizedBox(height: 24),

                // Points
                TextFormField(
                  controller: _pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Points *',
                    hintText: 'Enter points for this question',
                    prefixIcon: Icon(Icons.star),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Points are required';
                    }
                    final points = int.tryParse(value);
                    if (points == null || points < 1) {
                      return 'Enter a valid number (minimum 1)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Explanation (Optional)
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (Optional)',
                    hintText: 'Explain the correct answer',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Image URL (Optional)
                TextFormField(
                  initialValue: _imageUrl,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (Optional)',
                    hintText: 'Enter image URL',
                    prefixIcon: Icon(Icons.image),
                  ),
                  onChanged: (value) {
                    _imageUrl = value.isNotEmpty ? value : null;
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    widget.question == null ? 'Add Question' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build option field with radio button
  Widget _buildOptionField({
    required TextEditingController controller,
    required String label,
    required int index,
  }) {
    return Row(
      children: [
        Radio<int>(
          value: index,
          groupValue: _correctAnswerIndex,
          onChanged: (value) {
            setState(() => _correctAnswerIndex = value ?? 0);
          },
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'Enter option ${index + 1}',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Option ${index + 1} is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Save question
  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final question = QuestionModel(
      id: widget.question?.id ?? '',
      quizId: widget.question?.quizId ?? '',
      questionText: _questionController.text.trim(),
      options: [
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ],
      correctAnswerIndex: _correctAnswerIndex,
      points: int.parse(_pointsController.text),
      order: widget.question?.order ?? 0,
      questionImageUrl: _imageUrl,
      explanation: _explanationController.text.trim().isNotEmpty
          ? _explanationController.text.trim()
          : null,
    );

    widget.onSave(question);
  }
}
