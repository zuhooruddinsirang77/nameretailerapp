import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// Shows a modal sheet with the app's frame: drag handle, compact title, close
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
  return showAppSheetRaw<T>(
    context,
    isDismissible: isDismissible,
    builder: (ctx) => AppSheetFrame(
      title: title,
      subtitle: subtitle,
      headerAction: headerAction,
      footer: footerBuilder?.call(ctx),
      child: builder(ctx),
    ),
  );
}

/// Same presentation as [showAppSheet] but the caller supplies the whole
/// [AppSheetFrame] – needed when the footer depends on the sheet's own state.
Future<T?> showAppSheetRaw<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: builder,
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
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.gutter,
        AppSpace.md,
        AppSpace.sm,
        AppSpace.md,
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
                    child: Text(title, style: context.text.titleLarge),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      subtitle!,
                      style: context.text.bodySmall,
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
    );
    final handle = Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Center(
        child: ExcludeSemantics(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: p.borderStrong,
              borderRadius: AppRadius.brPill,
            ),
          ),
        ),
      ),
    );
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.gutter,
        AppSpace.sm,
        AppSpace.gutter,
        AppSpace.xl,
      ),
      child: child,
    );
    final actions = footer == null
        ? null
        : DecoratedBox(
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
          );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Short viewports (including an open keyboard) scroll as a whole
              // so the header and footer never squeeze a form out of view.
              if (constraints.maxHeight < 420 ||
                  (constraints.maxHeight < 600 &&
                      media.textScaler.scale(1) > 1.6)) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [handle, header, content, ?actions],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  handle,
                  header,
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: content,
                    ),
                  ),
                  ?actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
