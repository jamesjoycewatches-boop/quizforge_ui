import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge_ui/quizforge_ui.dart';

void main() {
  const first = QuizQuestion(
    id: 'q1',
    prompt: 'What is Flutter?',
    options: [
      QuizOption(id: 'a', label: 'An SDK'),
      QuizOption(id: 'b', label: 'A database'),
    ],
    correctOptionId: 'a',
    explanation: 'Flutter is a UI SDK.',
  );
  const second = QuizQuestion(
    id: 'q2',
    prompt: 'What is Dart?',
    options: [
      QuizOption(id: 'a', label: 'A database'),
      QuizOption(id: 'b', label: 'A language'),
    ],
    correctOptionId: 'b',
  );

  group('Question validation', () {
    test('rejects empty quiz', () {
      expect(() => QuizController(questions: []), throwsArgumentError);
    });

    test('rejects duplicate question IDs', () {
      expect(() => QuizController(questions: [first, first]), throwsArgumentError);
    });

    test('rejects missing correct option', () {
      const invalid = QuizQuestion(
        id: 'invalid',
        prompt: 'Pick one',
        options: [
          QuizOption(id: 'a', label: 'A'),
          QuizOption(id: 'b', label: 'B'),
        ],
        correctOptionId: 'missing',
      );
      expect(() => QuizController(questions: [invalid]), throwsArgumentError);
    });

    test('rejects duplicate option IDs', () {
      const invalid = QuizQuestion(
        id: 'invalid',
        prompt: 'Pick one',
        options: [
          QuizOption(id: 'a', label: 'A'),
          QuizOption(id: 'a', label: 'B'),
        ],
        correctOptionId: 'a',
      );
      expect(() => QuizController(questions: [invalid]), throwsArgumentError);
    });
  });

  group('QuizController', () {
    late QuizController controller;

    setUp(() => controller = QuizController(questions: [first, second]));
    tearDown(() => controller.dispose());

    test('starts clean, with read-only question and answer lists', () {
      expect(controller.currentIndex, 0);
      expect(controller.questionCount, 2);
      expect(controller.answeredCount, 0);
      expect(controller.progress, 0);
      expect(controller.canSubmit, isFalse);
      expect(controller.isCompleted, isFalse);
      expect(() => controller.questions.clear(), throwsUnsupportedError);
      expect(() => controller.answers.clear(), throwsUnsupportedError);
    });

    test('requires selecting a known answer', () {
      expect(controller.submit, throwsStateError);
      expect(controller.next, throwsStateError);
      expect(() => controller.selectOption('not-an-option'), throwsArgumentError);
    });

    test('allows changing answer before submission', () {
      controller.selectOption('b');
      controller.selectOption('a');
      expect(controller.selectedOptionId, 'a');
      controller.submit();
      expect(controller.answers.single.isCorrect, isTrue);
      expect(controller.selectedIsCorrect, isTrue);
      expect(controller.progress, 0.5);
      expect(() => controller.selectOption('b'), throwsStateError);
      expect(controller.submit, throwsStateError);
    });

    test('records wrong and right answers and completes', () {
      controller.selectOption('b');
      controller.submit();
      expect(controller.selectedIsCorrect, isFalse);
      controller.next();
      expect(controller.currentIndex, 1);
      expect(controller.selectedOptionId, isNull);
      controller.selectOption('b');
      controller.submit();
      expect(controller.isCompleted, isFalse);
      controller.next();
      expect(controller.isCompleted, isTrue);
      expect(controller.summary.correctAnswers, 1);
      expect(controller.summary.incorrectAnswers, 1);
      expect(controller.summary.scorePercent, 50);
      expect(controller.progress, 1);
      expect(controller.next, throwsStateError);
    });

    test('notifies listeners on changes and restarts cleanly', () {
      var updates = 0;
      controller.addListener(() => updates++);
      controller.selectOption('a');
      controller.submit();
      controller.next();
      controller.restart();
      expect(updates, 4);
      expect(controller.currentIndex, 0);
      expect(controller.answeredCount, 0);
      expect(controller.isSubmitted, isFalse);
      expect(controller.isCompleted, isFalse);
      expect(controller.summary.scorePercent, 0);
    });
  });
}
