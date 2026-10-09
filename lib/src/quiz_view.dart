import 'package:flutter/material.dart';

import 'quiz_controller.dart';
import 'quiz_models.dart';

/// A complete, responsive multiple-choice quiz experience.
///
/// Wrap this in a [MaterialApp]. The supplied [controller] is owned and
/// disposed by the caller. Content, accent, restart button and completion
/// callback can be customized without forking the package.
class QuizView extends StatelessWidget {
  const QuizView({
    super.key,
    required this.controller,
    this.title = 'Knowledge check',
    this.subtitle = 'Choose the best answer to each question.',
    this.accentColor,
    this.showExplanations = true,
    this.allowRestart = true,
    this.onCompleted,
  });

  final QuizController controller;
  final String title;
  final String subtitle;
  final Color? accentColor;
  final bool showExplanations;
  final bool allowRestart;
  final ValueChanged<QuizSummary>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final scheme = Theme.of(context).colorScheme;
          final accent = accentColor ?? scheme.primary;
          final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
          final duration = reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 240);
          final isCompact = constraints.maxWidth < 550;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 28,
              vertical: isCompact ? 24 : 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(title: title, subtitle: subtitle, accent: accent),
                    const SizedBox(height: 28),
                    if (controller.isCompleted)
                      _ResultPanel(
                        summary: controller.summary,
                        accent: accent,
                        allowRestart: allowRestart,
                        onRestart: controller.restart,
                      )
                    else ...[
                      _ProgressHeader(
                        currentIndex: controller.currentIndex,
                        questionCount: controller.questionCount,
                        answeredCount: controller.answeredCount,
                        accent: accent,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: duration,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _QuestionPanel(
                          key: ValueKey(controller.currentQuestion.id),
                          controller: controller,
                          accent: accent,
                          showExplanations: showExplanations,
                          duration: duration,
                          onContinue: () {
                            controller.next();
                            if (controller.isCompleted) {
                              onCompleted?.call(controller.summary);
                            }
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Built with QuizForge UI · No tracking or network access',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, required this.accent});

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.school_rounded, color: accent, size: 23),
            ),
            const SizedBox(width: 12),
            Text(
              'QUIZFORGE',
              style: theme.textTheme.labelLarge?.copyWith(
                color: accent,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.currentIndex,
    required this.questionCount,
    required this.answeredCount,
    required this.accent,
  });

  final int currentIndex;
  final int questionCount;
  final int answeredCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = answeredCount / questionCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentIndex + 1} of $questionCount',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$answeredCount / $questionCount answered',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: '$answeredCount of $questionCount questions answered',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: accent.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    super.key,
    required this.controller,
    required this.accent,
    required this.showExplanations,
    required this.duration,
    required this.onContinue,
  });

  final QuizController controller;
  final Color accent;
  final bool showExplanations;
  final Duration duration;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withAlpha(55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 12),
            color: scheme.shadow.withAlpha(12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SELECT ONE ANSWER',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.prompt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          for (final option in question.options) ...[
            _OptionTile(
              option: option,
              isSelected: controller.selectedOptionId == option.id,
              isSubmitted: controller.isSubmitted,
              isCorrect: question.correctOptionId == option.id,
              accent: accent,
              duration: duration,
              onTap: controller.isSubmitted
                  ? null
                  : () => controller.selectOption(option.id),
            ),
            const SizedBox(height: 10),
          ],
          if (controller.isSubmitted) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: controller.selectedIsCorrect
                      ? Colors.green.withAlpha(20)
                      : Colors.orange.withAlpha(24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedIsCorrect
                          ? 'Correct answer!'
                          : 'Not quite — keep learning.',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (showExplanations &&
                        question.explanation != null &&
                        question.explanation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(question.explanation!),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: _contrastForeground(accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: controller.isSubmitted
                  ? onContinue
                  : controller.canSubmit
                      ? controller.submit
                      : null,
              icon: Icon(controller.isSubmitted
                  ? Icons.arrow_forward_rounded
                  : Icons.check_rounded),
              label: Text(
                controller.isSubmitted
                    ? controller.isLastQuestion
                        ? 'See results'
                        : 'Next question'
                    : 'Submit answer',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.accent,
    required this.duration,
    required this.onTap,
  });

  final QuizOption option;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final Color accent;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlighted = isSubmitted ? isCorrect || isSelected : isSelected;
    final statusColor = isSubmitted
        ? isCorrect
            ? Colors.green.shade700
            : isSelected
                ? Colors.deepOrange.shade700
                : accent
        : accent;
    final background = highlighted ? statusColor.withAlpha(22) : scheme.surface;
    String? feedback;
    if (isSubmitted && isCorrect) feedback = 'Correct answer';
    if (isSubmitted && isSelected && !isCorrect) feedback = 'Incorrect selection';

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      label: '${option.label}${feedback == null ? '' : ', $feedback'}',
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: highlighted ? 2 : 1,
            color: highlighted ? statusColor : scheme.outline.withAlpha(80),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              child: Row(
                children: [
                  Icon(
                    isSubmitted && isCorrect
                        ? Icons.check_circle_rounded
                        : isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: highlighted ? statusColor : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      option.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                highlighted ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.summary,
    required this.accent,
    required this.allowRestart,
    required this.onRestart,
  });

  final QuizSummary summary;
  final Color accent;
  final bool allowRestart;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withAlpha(55)),
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withAlpha(25),
            ),
            child: Icon(Icons.emoji_events_rounded, color: accent, size: 38),
          ),
          const SizedBox(height: 18),
          Text(
            'Quiz complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              '${summary.scorePercent}%',
              style: theme.textTheme.displayLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${summary.correctAnswers} of ${summary.totalQuestions} correct',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Every question is progress. Keep exploring and keep learning.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (allowRestart) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: _contrastForeground(accent),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

Color _contrastForeground(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
