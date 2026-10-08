import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';

/// Navy sign-in/registration frame, independent of the device's theme.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
    this.errorMessage,
    this.errorTitle,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget footer;
  final String? errorMessage;
  final String? errorTitle;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.darkTheme,
    child: Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.heroStart,
          appBar: AppBar(
            backgroundColor: p.heroStart,
            leading: context.canPop()
                ? IconButton(
                    tooltip: 'Back',
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [p.heroStart, p.heroEnd],
                    ),
                  ),
                  child: const BrandArtwork(mesh: true),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.xl,
                      vertical: AppSpace.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - AppSpace.huge)
                            .clamp(0, double.infinity),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(child: BrandMark(size: 54)),
                              const SizedBox(height: AppSpace.md),
                              Text(
                                'NameRetailer',
                                textAlign: TextAlign.center,
                                style: context.text.headlineMedium?.copyWith(
                                  color: HeroPanel.on,
                                ),
                              ),
                              const SizedBox(height: AppSpace.xxl),
                              Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: context.text.headlineMedium?.copyWith(
                                    color: HeroPanel.on,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpace.sm),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: context.text.bodySmall?.copyWith(
                                  color: HeroPanel.onMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpace.xl),
                              MotionSize(
                                duration: AppMotion.of(context, AppMotion.fast),
                                child: errorMessage == null
                                    ? const SizedBox(width: double.infinity)
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpace.lg,
                                        ),
                                        child: InlineMessage(
                                          tone: MessageTone.danger,
                                          title: errorTitle,
                                          message: errorMessage!,
                                        ),
                                      ),
                              ),
                              ...children,
                              const SizedBox(height: AppSpace.xl),
                              footer,
                              const SizedBox(height: AppSpace.lg),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: HeroPanel.onMuted,
                                  ),
                                  const SizedBox(width: AppSpace.xs),
                                  Flexible(
                                    child: Text(
                                      'Your plans. Your private workspace.',
                                      textAlign: TextAlign.center,
                                      style: context.text.labelSmall?.copyWith(
                                        color: HeroPanel.onMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
