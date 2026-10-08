import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// Shows a modal sheet with the app's frame: drag handle, serif title, close
/// button, scrolling body and an optional pinned footer. It lifts above the
/// keyboard and is width-limited on tablets.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
  WidgetBuilder? footerBuilder,
  Widget? headerAction,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (ctx) => AppSheetFrame(
      title: title,
      subtitle: subtitle,
      headerAction: headerAction,
      footer: footerBuilder?.call(ctx),
      child: builder(ctx),
    ),
  );
}

class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.headerAction,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = MediaQuery.of(context);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      explicitChildNodes: true,
      child: AnimatedPadding(
        duration: AppMotion.of(context, AppMotion.fast),
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpace.sm),
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.borderStrong,
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  AppSpace.md,
                  AppSpace.sm,
                  AppSpace.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: context.text.headlineMedium,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: AppSpace.xxs),
                              Text(
                                subtitle!,
                                style: context.text.bodySmall
                                    ?.copyWith(color: p.textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ?headerAction,
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl,
                    AppSpace.sm,
                    AppSpace.xl,
                    AppSpace.xl,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: child,
                ),
              ),
              if (footer != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.surfaceRaised,
                    border: Border(top: BorderSide(color: p.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.lg),
                      child: footer,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
