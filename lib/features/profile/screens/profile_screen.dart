import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../marketplace/providers/shortlist_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _editName(String currentName) async {
    final newName = await showAppSheetRaw<String>(
      context,
      builder: (_) => _EditNameSheet(initial: currentName),
    );
    if (newName == null || newName.isEmpty || newName == currentName) return;
    HapticFeedback.lightImpact();
    final ok = await ref
        .read(authStateProvider.notifier)
        .updateProfile(newName);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Your name was updated.'
                : "We couldn't update your name. Please try again.",
          ),
        ),
      );
  }

  Future<void> _signOut() async {
    final ok = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      title: 'Sign out?',
      message:
          'Your planning cart stays safely attached to your account for when you sign back in.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (ok) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider.select((s) => s.user));
    final shortlistCount = ref.watch(shortlistProvider.select((l) => l.length));
    final cartCount = ref.watch(cartItemCountProvider);
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: context.pagePadding(top: AppSpace.sm),
        children: [
          _Header(
            name: user?.name,
            email: user?.email,
            onEdit: user == null ? null : () => _editName(user.name),
          ),
          const SizedBox(height: AppSpace.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(
                    value: '$shortlistCount',
                    label: 'Saved',
                    icon: Icons.favorite_rounded,
                    color: p.brandText,
                    onTap: () => context.push('/shortlist'),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: _StatCard(
                    value: '$cartCount',
                    label: 'In cart',
                    icon: Icons.shopping_bag_rounded,
                    color: p.successText,
                    onTap: () => context.go('/cart'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(title: 'Your activity'),
          const SizedBox(height: AppSpace.md),
          AppListGroup(
            children: [
              AppListTile(
                icon: Icons.favorite_border_rounded,
                title: 'Saved publications',
                subtitle: '$shortlistCount saved · compare side by side',
                onTap: () => context.push('/shortlist'),
              ),
              AppListTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Planning cart',
                subtitle: 'Review briefs, anchors and writing choices',
                onTap: () => context.go('/cart'),
              ),
              AppListTile(
                icon: Icons.receipt_long_outlined,
                title: 'Your orders',
                subtitle: 'Payment status and placement history',
                onTap: () => context.push('/orders'),
              ),
              AppListTile(
                icon: Icons.mail_outline_rounded,
                title: 'Send an inquiry',
                subtitle: 'Custom niches or high-volume orders',
                onTap: () => context.push('/inquiry'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(title: 'Resources'),
          const SizedBox(height: AppSpace.md),
          AppListGroup(
            children: [
              AppListTile(
                icon: Icons.help_outline_rounded,
                title: 'Buyer guide & FAQ',
                subtitle: 'Understand DR, DA and placement scope',
                onTap: () => context.push('/help'),
              ),
              AppListTile(
                icon: Icons.info_outline_rounded,
                title: 'About NameRetailer',
                subtitle: 'Who we are and how placements work',
                onTap: () => context.push('/about'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          if (user != null)
            AppButton(
              label: 'Sign out',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.large,
              expand: true,
              onPressed: _signOut,
            )
          else ...[
            AppButton(
              label: 'Sign in',
              icon: Icons.login_rounded,
              size: AppButtonSize.large,
              expand: true,
              onPressed: () => context.push('/login'),
            ),
            const SizedBox(height: AppSpace.sm),
            AppButton(
              label: 'Create an account',
              variant: AppButtonVariant.text,
              expand: true,
              onPressed: () => context.push('/register'),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  final String? name;
  final String? email;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final signedIn = name != null;
    final initial = signedIn && name!.isNotEmpty
        ? name!.characters.first.toUpperCase()
        : null;

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name ?? 'Guest',
          style: context.text.titleLarge?.copyWith(color: HeroPanel.on),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          email ?? 'Sign in to sync your cart and drafts',
          style: context.text.bodySmall?.copyWith(color: HeroPanel.onMuted),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    final avatar = Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
      child: initial == null
          ? const Icon(Icons.person_outline_rounded, color: HeroPanel.on)
          : Text(
              initial,
              style: context.text.headlineLarge?.copyWith(color: HeroPanel.on),
            ),
    );
    final edit = onEdit == null
        ? const SizedBox.shrink()
        : AppIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit name',
            color: HeroPanel.on,
            onPressed: onEdit,
          );
    return HeroPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.4) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [avatar, const Spacer(), edit]),
                const SizedBox(height: AppSpace.md),
                identity,
              ],
            );
          }
          return Row(
            children: [
              avatar,
              const SizedBox(width: AppSpace.md),
              Expanded(child: identity),
              edit,
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: '$value $label',
      excludeSemantics: true,
      onTap: onTap,
      child: AppCard(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.tint(color),
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              value,
              style: context.text.headlineMedium?.copyWith(
                color: p.text,
                fontFeatures: AppTypography.tabular,
              ),
            ),
            Text(
              label,
              style: context.text.labelMedium?.copyWith(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.initial});

  final String initial;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: 'Edit your name',
      subtitle: 'This is how you appear on orders and inquiries.',
      footer: AppButton(
        label: 'Save changes',
        size: AppButtonSize.large,
        expand: true,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: 'Full name',
          icon: Icons.person_outline_rounded,
          maxLength: 120,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.name],
          onSubmitted: (_) => _save(),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter your name' : null,
        ),
      ),
    );
  }
}
