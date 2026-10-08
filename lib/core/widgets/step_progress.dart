import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// Horizontal stepper: completed steps show a tick, the current step is
/// highlighted, upcoming steps are muted. Labels sit under the markers so it
/// fits 360dp screens.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.steps,
    required this.current,
  }) : assert(current >= 0);

  final List<String> steps;

  /// Zero-based index of the active step.
  final int current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dur = AppMotion.of(context);

    return Semantics(
      container: true,
      label: 'Step ${current + 1} of ${steps.length}: ${steps[current]}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : _Connector(active: i <= current, duration: dur),
                      ),
                      _Marker(
                        index: i,
                        state: i < current
                            ? _StepState.done
                            : i == current
                                ? _StepState.current
                                : _StepState.upcoming,
                        duration: dur,
                      ),
                      Expanded(
                        child: i == steps.length - 1
                            ? const SizedBox.shrink()
                            : _Connector(active: i < current, duration: dur),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      steps[i],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(
                        color: i == current ? p.text : p.textMuted,
                        fontWeight:
                            i == current ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _Marker extends StatelessWidget {
  const _Marker({
    required this.index,
    required this.state,
    required this.duration,
  });

  final int index;
  final _StepState state;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color fill, Color fg, Color line) = switch (state) {
      _StepState.done => (p.brand, p.onBrand, p.brand),
      _StepState.current => (p.brandSoft, p.brandText, p.brand),
      _StepState.upcoming => (p.surface, p.textMuted, p.borderStrong),
    };
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.standard,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: line, width: state == _StepState.current ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: state == _StepState.done
          ? Icon(Icons.check_rounded, size: 18, color: fg)
          : Text(
              '${index + 1}',
              style: context.text.labelMedium?.copyWith(color: fg),
            ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.active, required this.duration});

  final bool active;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: duration,
      height: 2,
      color: active ? p.brand : p.border,
    );
  }
}
