# QuizForge UI

**A beautiful, accessible, lightweight quiz toolkit for Flutter.**

QuizForge UI helps Flutter developers add a polished multiple-choice learning experience without building a question engine, answer feedback, progress bar, score screen, and accessibility support from scratch.

> **Project status:** Early preview (`0.1.0`). Community contributions and feedback welcome. This repository is not affiliated with OpenAI or Flutter.

## Features

- **Responsive UI:** Works on narrow phones, tablets, and desktop Flutter apps.
- **Accessible by default:** Semantic labels, focusable Material controls, live feedback, and reduced-animation support.
- **Learning feedback:** Clear correct/incorrect states and optional explanations.
- **State you control:** `QuizController` is deterministic and reusable; no backend required.
- **Scoring and progress:** Read-only answer history, completion summary, and restart.
- **Theme-aware:** Material 3, system dark mode, and custom accent color.
- **Privacy-friendly:** No analytics, accounts, networking, or data collection.
- **Small footprint:** No third-party runtime dependencies.

## Quick start

This package is intended to be installed from a GitHub repository initially; replace `YOUR_USERNAME` with the real owner after publishing the repository.

```yaml
# pubspec.yaml
dependencies:
  quizforge_ui:
    git:
      url: https://github.com/YOUR_USERNAME/quizforge_ui.git
      ref: v0.1.0
```

Or while developing locally:

```yaml
dependencies:
  quizforge_ui:
    path: ../quizforge_ui
```

```dart
import 'package:flutter/material.dart';
import 'package:quizforge_ui/quizforge_ui.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final QuizController quiz;

  @override
  void initState() {
    super.initState();
    quiz = QuizController(questions: const [
      QuizQuestion(
        id: 'sample',
        prompt: 'Which framework uses Dart?',
        options: [
          QuizOption(id: 'a', label: 'Flutter'),
          QuizOption(id: 'b', label: 'React'),
        ],
        correctOptionId: 'a',
        explanation: 'Flutter applications are built using Dart.',
      ),
    ]);
  }

  @override
  void dispose() {
    quiz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: QuizView(
          controller: quiz,
          title: 'Practice time',
          accentColor: const Color(0xFF5A47D5),
          onCompleted: (result) {
            debugPrint('Score: ${result.scorePercent}%');
          },
        ),
      ),
    );
  }
}
```

Supply `PracticePage` as the `home` of a `MaterialApp`.

## Run the example

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then:

```bash
cd example
flutter create --platforms=android,ios,web,macos,windows,linux .
flutter pub get
flutter run -d chrome   # or an Android/iOS device
```

## API at a glance

| Symbol | Purpose |
|---|---|
| `QuizOption` | Stable option ID and display label |
| `QuizQuestion` | Question, options, correct ID, optional explanation |
| `QuizController` | Select, submit, advance, restart; scoring and progress |
| `QuizAnswer` | Read-only outcome of a submitted answer |
| `QuizSummary` | Correct count, incorrect count, score fraction/percent |
| `QuizView` | All-in-one responsive quiz UI |

### Controller lifecycle

`selectOption(id)` → `submit()` → `next()` → repeat, then `isCompleted == true`. A submission requires an existing selected option; invalid state transitions raise `StateError`. Caller owns the controller and must dispose it in `dispose()`.

### Validation

The controller rejects empty question lists, repeated question IDs, duplicate option IDs, fewer than two options, and incorrect answer IDs that do not exist in the question. IDs are case-sensitive.

## Run tests and checks

```bash
flutter pub get
flutter analyze
flutter test
cd example && flutter pub get && flutter analyze
```

CI repeats these checks for pull requests and pushes to `main`.

## Architecture and privacy

```text
QuizQuestion / QuizOption (data)
            ↓
QuizController (ChangeNotifier state machine)
            ↓
QuizView (Material 3 widgets + accessibility)
```

Quiz data and answers remain in process memory. This toolkit neither persists them nor transmits them. Apps integrating QuizForge can implement their own storage or analytics independently.

## Roadmap

- [ ] Internationalization hooks for built-in UI strings
- [ ] Randomized options with stable seeded order
- [ ] Optional timed practice mode
- [ ] More accessibility testing with assistive technologies
- [ ] Community-provided themes and samples

## Contribute

New to GitHub? See the [Roman Urdu setup guide](SETUP_ROMAN_URDU.md).

See [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and [SECURITY.md](SECURITY.md). Bug reports, docs fixes, accessible UX improvements, and independent sample quizzes are welcome.

## License

[MIT](LICENSE) © 2026 QuizForge UI Contributors.
