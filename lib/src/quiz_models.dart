import 'package:flutter/foundation.dart';

/// A stable ID and human-readable label for one answer choice.
@immutable
class QuizOption {
  const QuizOption({required this.id, required this.label})
      : assert(id != ''),
        assert(label != '');

  final String id;
  final String label;
}

/// A multiple-choice question with exactly one correct choice.
///
/// Validation of distinct IDs and correct option membership occurs when the
/// question is added to a [QuizController].
@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    this.explanation,
  })  : assert(id != ''),
        assert(prompt != ''),
        assert(options.length >= 2),
        assert(correctOptionId != '');

  final String id;
  final String prompt;
  final List<QuizOption> options;
  final String correctOptionId;
  final String? explanation;
}

/// The immutable outcome of one submitted answer.
@immutable
class QuizAnswer {
  const QuizAnswer({
    required this.questionId,
    required this.selectedOptionId,
    required this.correctOptionId,
  });

  final String questionId;
  final String selectedOptionId;
  final String correctOptionId;

  bool get isCorrect => selectedOptionId == correctOptionId;
}

/// Final quiz statistics (calculated only from submitted answers).
@immutable
class QuizSummary {
  const QuizSummary({required this.totalQuestions, required this.correctAnswers});

  final int totalQuestions;
  final int correctAnswers;

  int get incorrectAnswers => totalQuestions - correctAnswers;
  double get scoreFraction => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
  int get scorePercent => (scoreFraction * 100).round();
}
