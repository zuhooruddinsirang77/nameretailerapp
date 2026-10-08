import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../marketplace/providers/shortlist_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _editNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Customer Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Customer Name'),
          maxLength: 120,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.of(ctx).pop();
                HapticFeedback.lightImpact();
                final success = await ref
                    .read(authStateProvider.notifier)
                    .updateProfile(newName);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account profile updated successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final shortlistCount = ref.watch(shortlistProvider).length;
    final cartCount = ref.watch(cartItemCountProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space16),
        children: [
          // Executive Customer Profile Header Card
          Container(
            padding: const EdgeInsets.all(AppDimens.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                    : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              boxShadow: AppDimens.shadowCard(isDark),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        user != null && user.name.isNotEmpty
                            ? user.name.substring(0, 1).toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Guest Customer',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (user != null) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.accentEmerald, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? 'Sign in to access saved placements',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (user != null) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _editNameDialog(user.name),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Name', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Activity Stats Quick Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Saved Shortlist',
                  value: '$shortlistCount',
                  icon: Icons.bookmark_added_rounded,
                  color: AppColors.accentAmber,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/shortlist');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Planning Cart',
                  value: '$cartCount',
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.accentEmerald,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/cart');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Customer Activity
          AppSectionHeader(
            title: 'Customer Placements',
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'Publication Shortlist',
                  subtitle: '$shortlistCount publications saved for comparison',
                  onTap: () => context.push('/shortlist'),
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                _buildMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Planning Cart & Drafts',
                  subtitle: 'Review configured anchor text & writing choices',
                  onTap: () => context.go('/cart'),
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                _buildMenuTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Placement Inquiries',
                  subtitle: 'Direct questions on niche topics or custom requirements',
                  onTap: () => context.push('/inquiry'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Marketplace Guides & Transparency
          AppSectionHeader(
            title: 'Resources & Information',
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Buyer Essentials & SEO Guide',
                  subtitle: 'Understanding DR, DA, and placement scope',
                  onTap: () => context.push('/help'),
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                _buildMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About NameRetailer',
                  subtitle: 'Marketplace platform overview and terms',
                  onTap: () => context.push('/about'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Action: Sign In or Sign Out
          if (user != null)
            AppButton(
              text: 'Sign Out of Customer Account',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.large,
              isFullWidth: true,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text(
                      'Are you sure you want to sign out? Your saved planning cart will remain safely attached to your account upon signing back in.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  HapticFeedback.mediumImpact();
                  await ref.read(authStateProvider.notifier).logout();
                }
              },
            )
          else
            AppButton(
              text: 'Sign In to Customer Account',
              icon: Icons.login_rounded,
              size: AppButtonSize.large,
              isFullWidth: true,
              onPressed: () => context.push('/login'),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
        boxShadow: AppDimens.shadowSubtle(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.accent),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
