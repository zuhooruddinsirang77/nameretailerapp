import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/checkout.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCountry = 'US';
  String _paymentPreference = 'stripe';
  bool _saving = false;
  bool _initializedFromDraft = false;

  final List<Map<String, String>> _countries = const [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'AE', 'name': 'United Arab Emirates'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'PK', 'name': 'Pakistan'},
    {'code': 'SG', 'name': 'Singapore'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFromDraft(CheckoutDraft? draft) {
    if (_initializedFromDraft || draft == null) return;
    _initializedFromDraft = true;

    _emailController.text = draft.billing.email;
    _firstNameController.text = draft.billing.firstName;
    _lastNameController.text = draft.billing.lastName;
    _streetController.text = draft.billing.street;
    _apartmentController.text = draft.billing.apartment;
    _cityController.text = draft.billing.city;
    _regionController.text = draft.billing.region;
    _postalCodeController.text = draft.billing.postalCode;
    _phoneController.text = draft.billing.phone;
    _notesController.text = draft.notes;
    _selectedCountry = draft.billing.country.isNotEmpty ? draft.billing.country : 'US';
    _paymentPreference = draft.paymentPreference.isNotEmpty ? draft.paymentPreference : 'stripe';
  }

  Future<void> _submitCheckout() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final billing = BillingDetails(
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      country: _selectedCountry,
      street: _streetController.text.trim(),
      apartment: _apartmentController.text.trim(),
      city: _cityController.text.trim(),
      region: _regionController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final success = await ref.read(checkoutProvider.notifier).saveDraft(
          billing: billing,
          notes: _notesController.text.trim(),
          paymentPreference: _paymentPreference,
        );

    setState(() => _saving = false);

    if (mounted) {
      if (success) {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 52),
            title: const Text('Checkout Draft Confirmed'),
            content: const Text(
              'Your placement configuration and billing details have been safely stored. A private 7-day reservation has been created for your order.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/cart');
                },
                child: const Text('Back to Cart'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save checkout draft. Please check your data.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final checkoutAsync = ref.watch(checkoutProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout Review')),
        body: AppEmptyState(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.accent,
          title: 'Sign In Required for Checkout',
          description:
              'Please sign in to your customer account to review placement briefs and confirm billing details.',
          actionText: 'Sign In',
          onActionTap: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Review & Billing')),
      body: checkoutAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Preparing checkout summary…'),
            ],
          ),
        ),
        error: (err, _) => AppEmptyState(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          title: 'Unable to Load Checkout',
          description: err.toString(),
          actionText: 'Retry',
          onActionTap: () => ref.read(checkoutProvider.notifier).loadCheckout(),
        ),
        data: (view) {
          _populateFromDraft(view.draft);

          final totalCents = view.cart.totalCents ??
              view.cart.items.fold<int>(0, (sum, item) => sum + (item.totalCents ?? 0));

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.space16),
              children: [
                // Step Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkCard : Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStepItem('1', 'Catalog', false),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textMutedLight),
                      _buildStepItem('2', 'Planning Cart', false),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textMutedLight),
                      _buildStepItem('3', 'Review & Draft', true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Security Preview Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: AppColors.accentEmerald.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: AppColors.accentEmerald, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Draft Safe Preview: No charges will be processed today. Your order details are saved privately for 7 days.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Customer Billing Details
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Billing Contact Information',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                AppCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Billing Email Address *',
                          prefixIcon: Icon(Icons.email_outlined, size: 18),
                        ),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Please provide a valid billing email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(labelText: 'First Name *'),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(labelText: 'Last Name *'),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCountry,
                        decoration: const InputDecoration(labelText: 'Country / Territory *'),
                        items: _countries.map((c) {
                          return DropdownMenuItem(value: c['code'], child: Text(c['name']!));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCountry = val ?? 'US'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(labelText: 'Street Address *'),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Street address required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _apartmentController,
                        decoration: const InputDecoration(labelText: 'Suite / Apt (Optional)'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(labelText: 'City *'),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'City required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _regionController,
                              decoration: const InputDecoration(labelText: 'State / Region'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(labelText: 'Postal Code'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Phone'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 2: Payment Preference
                Row(
                  children: [
                    const Icon(Icons.payment_rounded, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Preferred Payment Channel',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentOption('stripe', 'Credit Card (Stripe)', Icons.credit_card_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPaymentOption('paypal', 'PayPal / Balance', Icons.account_balance_wallet_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Section 3: Campaign & Order Notes
                Row(
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Campaign Notes (Optional)',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Special timing instructions, publication preferences, or reference numbers…',
                  ),
                ),
                const SizedBox(height: 20),

                // Section 4: Order Summary Review
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Order Summary',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...view.cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  Formatters.cleanDomain(item.domain ?? 'Publication'),
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(item.totalCents),
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Order Total:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            Formatters.formatCurrency(totalCents),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentEmerald,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm CTA
                AppButton(
                  text: 'Confirm & Save Checkout Draft',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _saving,
                  size: AppButtonSize.large,
                  isFullWidth: true,
                  onPressed: _submitCheckout,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String number, String label, bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.cardBorderLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.accent : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String key, String label, IconData icon) {
    final isSelected = _paymentPreference == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _paymentPreference = key);
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.surfaceDarkCard : Colors.white),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMutedLight,
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: isSelected ? AppColors.accent : null),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
