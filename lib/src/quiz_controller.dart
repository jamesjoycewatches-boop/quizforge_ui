import 'package:flutter/foundation.dart';

import 'quiz_models.dart';

/// Owns the quiz's small and deterministic state machine.
///
/// Question ordering is preserved. Answers are not retained after [restart].
/// The controller owns no timers, subscriptions, network calls, or analytics.
class QuizController extends ChangeNotifier {
  QuizController({required List<QuizQuestion> questions})
      : _questions = List<QuizQuestion>.unmodifiable(
          questions.map(
            (question) => QuizQuestion(
              id: question.id,
              prompt: question.prompt,
              options: List<QuizOption>.unmodifiable(question.options),
              correctOptionId: question.correctOptionId,
              explanation: question.explanation,
            ),
          ),
        ) {
    _validateQuestions(_questions);
  }

  final List<QuizQuestion> _questions;
  final List<QuizAnswer> _answers = <QuizAnswer>[];
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _submitted = false;
  bool _completed = false;

  List<QuizQuestion> get questions => _questions;
  List<QuizAnswer> get answers => List<QuizAnswer>.unmodifiable(_answers);
  QuizQuestion get currentQuestion => _questions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get questionCount => _questions.length;
  int get answeredCount => _answers.length;
  String? get selectedOptionId => _selectedOptionId;
  bool get isSubmitted => _submitted;
  bool get isCompleted => _completed;
  bool get canSubmit => !_completed && !_submitted && _selectedOptionId != null;
  bool get isLastQuestion => _currentIndex == _questions.length - 1;
  bool get selectedIsCorrect =>
      _submitted && _selectedOptionId == currentQuestion.correctOptionId;
  double get progress => _answers.length / _questions.length;

  QuizSummary get summary => QuizSummary(
        totalQuestions: questionCount,
        correctAnswers: _answers.where((answer) => answer.isCorrect).length,
      );

  /// Choose an option; this can be changed until the question is submitted.
  void selectOption(String optionId) {
    if (_completed || _submitted) {
      throw StateError('Cannot select an option after submission.');
    }
    if (!currentQuestion.options.any((option) => option.id == optionId)) {
      throw ArgumentError.value(optionId, 'optionId', 'Unknown option.');
    }
    if (_selectedOptionId == optionId) return;
    _selectedOptionId = optionId;
    notifyListeners();
  }

  /// Lock the current selection and record whether it was correct.
  void submit() {
    if (!canSubmit) {
      throw StateError('Select an option before submitting.');
    }
    _answers.add(QuizAnswer(
      questionId: currentQuestion.id,
      selectedOptionId: _selectedOptionId!,
      correctOptionId: currentQuestion.correctOptionId,
    ));
    _submitted = true;
    notifyListeners();
  }

  /// Advance after submission, or show completion after the last question.
  void next() {
    if (!_submitted || _completed) {
      throw StateError('Submit the current answer before continuing.');
    }
    if (isLastQuestion) {
      _completed = true;
    } else {
      _currentIndex++;
      _submitted = false;
      _selectedOptionId = null;
    }
    notifyListeners();
  }

  /// Start over, clearing all answers and selections.
  void restart() {
    _currentIndex = 0;
    _selectedOptionId = null;
    _submitted = false;
    _completed = false;
    _answers.clear();
    notifyListeners();
  }

  static void _validateQuestions(List<QuizQuestion> questions) {
    if (questions.isEmpty) {
      throw ArgumentError.value(questions, 'questions', 'Quiz cannot be empty.');
    }
    final questionIds = <String>{};
    for (final question in questions) {
      if (question.id.trim().isEmpty || question.prompt.trim().isEmpty) {
        throw ArgumentError('Question IDs and prompts must be non-empty.');
      }
      if (!questionIds.add(question.id)) {
        throw ArgumentError('Duplicate question ID: ${question.id}');
      }
      if (question.options.length < 2) {
        throw ArgumentError('Every question requires at least two options.');
      }
      final optionIds = <String>{};
      for (final option in question.options) {
        if (option.id.trim().isEmpty || option.label.trim().isEmpty) {
          throw ArgumentError('Option IDs and labels must be non-empty.');
        }
        if (!optionIds.add(option.id)) {
          throw ArgumentError('Duplicate option ID in ${question.id}: ${option.id}');
        }
      }
      if (!optionIds.contains(question.correctOptionId)) {
        throw ArgumentError('Correct option ID not found in ${question.id}.');
      }
    }
  }
}
