import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge_ui/quizforge_ui.dart';

void main() {
  const questions = <QuizQuestion>[
    QuizQuestion(
      id: 'q1',
      prompt: 'Which choice is correct?',
      options: [
        QuizOption(id: 'right', label: 'The right answer'),
        QuizOption(id: 'wrong', label: 'The wrong answer'),
      ],
      correctOptionId: 'right',
      explanation: 'This is why the answer is correct.',
    ),
  ];

  testWidgets('completes quiz, announces feedback and restarts', (tester) async {
    final controller = QuizController(questions: questions);
    addTearDown(controller.dispose);
    QuizSummary? completed;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuizView(
          controller: controller,
          onCompleted: (summary) => completed = summary,
        ),
      ),
    ));

    expect(find.text('Which choice is correct?'), findsOneWidget);
    expect(find.text('Question 1 of 1'), findsOneWidget);
    expect(find.text('Submit answer'), findsOneWidget);

    await tester.tap(find.text('The right answer'));
    await tester.pump();
    await tester.ensureVisible(find.text('Submit answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();

    expect(find.text('Correct answer!'), findsOneWidget);
    expect(find.text('This is why the answer is correct.'), findsOneWidget);
    await tester.ensureVisible(find.text('See results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See results'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz complete!'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(completed?.correctAnswers, 1);

    await tester.ensureVisible(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Which choice is correct?'), findsOneWidget);
    expect(controller.answeredCount, 0);
  });

  testWidgets('wrong answer shows explanatory feedback', (tester) async {
    final controller = QuizController(questions: questions);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuizView(controller: controller)),
    ));
    await tester.tap(find.text('The wrong answer'));
    await tester.pump();
    await tester.ensureVisible(find.text('Submit answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();
    expect(find.text('Not quite — keep learning.'), findsOneWidget);
  });

  testWidgets('hides explanations when disabled', (tester) async {
    final controller = QuizController(questions: questions);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuizView(controller: controller, showExplanations: false),
      ),
    ));
    await tester.tap(find.text('The right answer'));
    await tester.pump();
    await tester.ensureVisible(find.text('Submit answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();
    expect(find.text('This is why the answer is correct.'), findsNothing);
  });
  
testWidgets('countdown displays time and timeout feedback',
    (tester) async {
  final controller = QuizController(
    questions: questions,
    questionTimeLimit: const Duration(seconds: 2),
  );

  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: QuizView(controller: controller),
      ),
    ),
  );

  expect(find.text('2s remaining'), findsOneWidget);
  expect(controller.isTimedOut, isFalse);

  await tester.pump(const Duration(seconds: 1));

  expect(find.text('1s remaining'), findsOneWidget);

  await tester.pump(const Duration(seconds: 1));

  expect(find.text('0s remaining'), findsOneWidget);
  expect(controller.isTimedOut, isTrue);
  expect(controller.isSubmitted, isTrue);

  expect(
    find.text('Time is up! This question was marked unanswered.'),
    findsOneWidget,
  );

  expect(controller.answeredCount, 1);
  expect(controller.answers.single.isCorrect, isFalse);
});

}
