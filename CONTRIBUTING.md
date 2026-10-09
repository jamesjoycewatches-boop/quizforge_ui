# Contributing to QuizForge UI

Thank you for helping make Flutter learning interfaces better.

## Before you start

1. Check existing issues and discussions to avoid duplicate work.
2. For significant changes, open an issue explaining the problem, suggested solution, and impact on accessibility or existing users.
3. Avoid submitting copyrighted learning materials, private customer data, proprietary code, tokens, or credentials.

## Development workflow

1. Fork the project and create a descriptive feature branch.
2. Install Flutter (compatible with `pubspec.yaml`).
3. Run `flutter pub get`, `flutter analyze`, and `flutter test`.
4. Add or update tests for new behavior. Prefer narrow changes.
5. Format with `dart format lib test example/lib`.
6. Open a pull request explaining motivation, changes, tests, and any breaking APIs.

## Project principles

- Accessible, keyboard-friendly controls and screen-reader semantics.
- No third-party runtime dependencies unless strongly justified.
- Keep data and quiz logic separate from UI.
- Avoid any automatic data collection, tracking, or network calls.
- Backwards-compatible public APIs where practical.

## Maintainers

After publication, list actual maintainers and use GitHub Issues and pull requests to document the ongoing maintenance history. No specific contribution, review, or acceptance timeline is promised.
