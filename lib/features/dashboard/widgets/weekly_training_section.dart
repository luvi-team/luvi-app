import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/domain/weekly_training_props.dart';
import 'package:luvi_app/features/dashboard/widgets/weekly_training_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class WeeklyTrainingSection extends StatelessWidget {
  const WeeklyTrainingSection({
    super.key,
    required this.trainings,
    required this.onTrainingTap,
  });

  final List<WeeklyTrainingProps> trainings;
  final void Function(String trainingId) onTrainingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final typographyTokens = theme.extension<WorkoutCardTypographyTokens>();

    final titleStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 24 / 20,
      color: theme.colorScheme.onSurface,
    );
    final subtitleStyle =
        typographyTokens?.sectionSubtitleStyle ??
        TextStyle(
          fontFamily: FontFamilies.figtree,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 24 / 16,
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        );

    final peekPadding = math.min(60.0, _weeklyTrainingCardWidth(context) * 0.2);

    return Column(
      key: const Key('dashboard_weekly_training_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.l),
          child: Text(l10n.dashboardTrainingWeekTitle, style: titleStyle),
        ),
        const SizedBox(height: _weeklyTitleSubtitleGap),
        Padding(
          padding: const EdgeInsets.only(left: Spacing.l),
          child: Text(l10n.dashboardTrainingWeekSubtitle, style: subtitleStyle),
        ),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: _weeklyTrainingCardHeight,
          child: Stack(
            children: [
              ListView.separated(
                padding: EdgeInsets.only(left: Spacing.l, right: peekPadding),
                scrollDirection: Axis.horizontal,
                itemCount: trainings.length,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: _weeklyTrainingItemGap),
                itemBuilder: (context, index) {
                  final training = trainings[index];
                  return RepaintBoundary(
                    child: WeeklyTrainingCard(
                      title: training.title,
                      subtitle: training.subtitle,
                      imagePath: training.imagePath,
                      dayLabel: training.dayLabel,
                      duration: training.duration,
                      isCompleted: training.isCompleted,
                      onTap: () => onTrainingTap(training.id),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: Spacing.l + peekPadding,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white,
                              Colors.white,
                              Colors.transparent
                            ],
                            stops: [0.0, 0.85, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: const ColoredBox(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _weeklyTrainingCardWidth(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = viewportWidth - _weeklyTrainingHorizontalInset;
    return math.min(_weeklyTrainingCardMaxWidth, availableWidth);
  }
}

const double _weeklyTrainingCardHeight = 280.0;
const double _weeklyTrainingCardMaxWidth = 340.0;
const double _weeklyTrainingHorizontalInset = 48.0;
const double _weeklyTrainingItemGap = 17.0;
const double _weeklyTitleSubtitleGap = 4.0;
