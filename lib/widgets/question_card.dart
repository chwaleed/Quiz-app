import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testproject/models/question_model.dart';

/// Reusable widget for displaying a question with multiple choice options
class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isReview;
  final int? correctAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.isReview = false,
    this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            Text(
              question.questionText,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Question Image (if available)
            if (question.questionImageUrl != null &&
                question.questionImageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: question.questionImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

            if (question.questionImageUrl != null &&
                question.questionImageUrl!.isNotEmpty)
              const SizedBox(height: 20),

            // Options
            ...List.generate(
              question.options.length,
              (index) =>
                  _buildOptionTile(context, index, question.options[index]),
            ),

            // Points Display
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${question.points} points',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Explanation (only in review mode)
            if (isReview &&
                question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Explanation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, int index, String option) {
    final bool isSelected = selectedAnswer == index;
    final bool isCorrectOption = correctAnswer == index;
    final bool isWrongSelection = isReview && isSelected && !isCorrectOption;

    Color? tileColor;
    Color? borderColor;
    IconData? icon;
    Color? iconColor;

    if (isReview) {
      // In review mode, always highlight the correct answer in green
      if (isCorrectOption) {
        tileColor = Colors.green.shade50;
        borderColor = Colors.green;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      }
      // If user selected a wrong answer, highlight it in red
      else if (isWrongSelection) {
        tileColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      tileColor = Theme.of(context).primaryColor.withOpacity(0.1);
      borderColor = Theme.of(context).primaryColor;
      icon = Icons.radio_button_checked;
      iconColor = Theme.of(context).primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isReview ? null : () => onAnswerSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tileColor ?? Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Option Letter (A, B, C, D)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor?.withOpacity(0.2) ?? Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor ?? Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Option Text
              Expanded(
                child: Text(option, style: const TextStyle(fontSize: 16)),
              ),

              // Selection Icon
              if (icon != null) Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
