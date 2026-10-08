import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';

/// Shared frame for sign-in and registration: calm, centred, one column.
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
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.gutter,
              vertical: AppSpace.lg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppSpace.xl,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const BrandMark(size: 44),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NameRetailer',
                                  style: context.text.titleMedium,
                                ),
                                Text(
                                  'Customer account',
                                  style: context.text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.xl),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: context.text.displaySmall,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        subtitle,
                        style: context.text.bodyMedium?.copyWith(
                          color: p.textSecondary,
                        ),
                        textAlign: TextAlign.start,
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
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      footer,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
