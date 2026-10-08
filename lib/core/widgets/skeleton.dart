import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// Wraps a subtree of [SkeletonBox]es with a single shared shimmer sweep (one
/// animation controller no matter how many placeholders). Static when the user
/// prefers reduced motion. Announced to screen readers as "Loading".
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.semanticLabel = 'Loading',
  });

  final Widget child;
  final String semanticLabel;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final highlight = context.isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.75);

    Widget content = ExcludeSemantics(child: widget.child);
    if (!reduce) {
      content = AnimatedBuilder(
        animation: _controller,
        child: content,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: [
              p.skeleton,
              Color.alphaBlend(highlight, p.skeleton),
              p.skeleton,
            ],
            stops: const [0.25, 0.5, 0.75],
            transform: _SlideTransform(_controller.value),
          ).createShader(rect),
          child: child,
        ),
      );
    }
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: content,
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Sweep from fully left of the box to fully right.
    return Matrix4.translationValues(bounds.width * (t * 2 - 1) * 1.2, 0, 0);
  }
}

/// A solid placeholder block. Must live under a [SkeletonLoader].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.skeleton,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.palette.skeleton,
      shape: BoxShape.circle,
    ),
  );
}

class _SkeletonCardFrame extends StatelessWidget {
  const _SkeletonCardFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}

/// Placeholder shaped like a catalogue card.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 44, height: 44, radius: AppRadius.md),
              SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 16),
                    SizedBox(height: AppSpace.sm),
                    SkeletonBox(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.lg),
          SkeletonBox(height: 68, radius: AppRadius.md),
          SizedBox(height: AppSpace.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 90, height: 24),
              SkeletonBox(width: 120, height: 48, radius: AppRadius.md),
            ],
          ),
        ],
      ),
    );
  }
}

/// A vertical list of [ProductCardSkeleton]s inside a [SkeletonLoader].
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key, this.count = 4, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      semanticLabel: 'Loading publications',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? const EdgeInsets.all(AppSpace.gutter),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
        itemBuilder: (_, _) => const ProductCardSkeleton(),
      ),
    );
  }
}

/// Placeholder for the cart / summary list items.
class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 40, height: 40, radius: AppRadius.md),
              SizedBox(width: AppSpace.md),
              Expanded(child: SkeletonBox(height: 16)),
            ],
          ),
          SizedBox(height: AppSpace.md),
          SkeletonBox(width: 180, height: 12),
          SizedBox(height: AppSpace.md),
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonBox(width: 80, height: 20),
          ),
        ],
      ),
    );
  }
}

/// Generic block of text-like lines in a card (forms, summaries).
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key, this.fields = 5});

  final int fields;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      semanticLabel: 'Loading',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.gutter),
        children: [
          const SkeletonBox(height: 56, radius: AppRadius.md),
          const SizedBox(height: AppSpace.xl),
          for (var i = 0; i < fields; i++) ...[
            const SkeletonBox(height: 56, radius: AppRadius.md),
            const SizedBox(height: AppSpace.md),
          ],
        ],
      ),
    );
  }
}

/// Placeholder for the domain detail screen.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      semanticLabel: 'Loading publication',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.gutter),
        children: [
          const SkeletonBox(height: 200, radius: AppRadius.xl),
          const SizedBox(height: AppSpace.xl),
          const SkeletonBox(width: 180, height: 22),
          const SizedBox(height: AppSpace.md),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 92, radius: AppRadius.md)),
              SizedBox(width: AppSpace.md),
              Expanded(child: SkeletonBox(height: 92, radius: AppRadius.md)),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 92, radius: AppRadius.md)),
              SizedBox(width: AppSpace.md),
              Expanded(child: SkeletonBox(height: 92, radius: AppRadius.md)),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          const SkeletonBox(height: 120, radius: AppRadius.lg),
        ],
      ),
    );
  }
}
