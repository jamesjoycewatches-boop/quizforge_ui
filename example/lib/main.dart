import 'package:flutter/material.dart';
import 'package:quizforge_ui/quizforge_ui.dart';

void main() => runApp(const QuizForgeExample());

class QuizForgeExample extends StatelessWidget {
  const QuizForgeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuizForge UI Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A47D5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9988FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  late final QuizController controller;

  @override
  void initState() {
    super.initState();
    controller = QuizController(questions: demoQuestions);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: QuizView(
          controller: controller,
          title: 'Build better, learn faster.',
          subtitle: 'A small quiz about thoughtful software development.',
          onCompleted: (summary) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You scored ${summary.scorePercent}%!'),
              ),
            );
          },
        ),
      ),
    );
  }
}

const demoQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'accessibility',
    prompt: 'Which choice helps make a mobile app accessible?',
    options: [
      QuizOption(id: 'a', label: 'Using color alone to show errors'),
      QuizOption(id: 'b', label: 'Providing descriptive labels for controls'),
      QuizOption(id: 'c', label: 'Disabling keyboard navigation'),
    ],
    correctOptionId: 'b',
    explanation: 'Accessible labels help screen-reader users understand controls.',
  ),
  QuizQuestion(
    id: 'testing',
    prompt: 'Why should developers write automated tests?',
    options: [
      QuizOption(id: 'a', label: 'To catch regressions when code changes'),
      QuizOption(id: 'b', label: 'To guarantee that bugs never happen'),
      QuizOption(id: 'c', label: 'To avoid user feedback'),
    ],
    correctOptionId: 'a',
    explanation: 'Tests make it easier to spot unexpected behavior after changes.',
  ),
  QuizQuestion(
    id: 'privacy',
    prompt: 'What is a privacy-friendly default for a learning component?',
    options: [
      QuizOption(id: 'a', label: 'Send answers to an unknown server'),
      QuizOption(id: 'b', label: 'Collect identifiers without consent'),
      QuizOption(id: 'c', label: 'Keep quiz progress locally in memory'),
    ],
    correctOptionId: 'c',
    explanation: 'The QuizForge controller keeps answers in memory, not online.',
  ),
];
