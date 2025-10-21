import '../models/question.dart';

List<Question> getQuizQuestions() {
  return [
    Question(
      questionText: 'What is Flutter?',
      options: [
        'A programming language',
        'A UI framework',
        'A database',
        'An operating system',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which language is used to write Flutter apps?',
      options: ['Java', 'Kotlin', 'Dart', 'Swift'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What is a Widget in Flutter?',
      options: [
        'A type of variable',
        'A building block of UI',
        'A database table',
        'A network request',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which company developed Flutter?',
      options: ['Facebook', 'Apple', 'Google', 'Microsoft'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What does setState() do in Flutter?',
      options: [
        'Deletes the app state',
        'Updates the UI after state changes',
        'Saves data to database',
        'Creates a new widget',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which widget is used for scrollable lists?',
      options: ['Container', 'Column', 'ListView', 'Row'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What is hot reload in Flutter?',
      options: [
        'Restarting the device',
        'Quickly seeing code changes without losing state',
        'Overheating prevention',
        'A debugging tool',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which of these is a stateful widget?',
      options: ['Text', 'Icon', 'Checkbox', 'All widgets are stateful'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What is pubspec.yaml used for?',
      options: [
        'Writing tests',
        'Managing dependencies and project metadata',
        'Storing user data',
        'Creating widgets',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which layout widget arranges children vertically?',
      options: ['Row', 'Column', 'Stack', 'Grid'],
      correctAnswerIndex: 1,
    ),
  ];
}
