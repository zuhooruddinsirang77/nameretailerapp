import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
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

  final _emailFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _cityFocus = FocusNode();

  String _selectedCountry = 'US';
  String _paymentPreference = 'stripe';
  bool _saving = false;
  bool _initializedFromDraft = false;
  int _step = 0;
  final _scrollController = ScrollController();

  static const List<({String code, String name})> _countries = [
    (code: 'US', name: 'United States'),
    (code: 'GB', name: 'United Kingdom'),
    (code: 'CA', name: 'Canada'),
    (code: 'AU', name: 'Australia'),
    (code: 'DE', name: 'Germany'),
    (code: 'FR', name: 'France'),
    (code: 'AE', name: 'United Arab Emirates'),
    (code: 'IN', name: 'India'),
    (code: 'PK', name: 'Pakistan'),
    (code: 'SG', name: 'Singapore'),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in [
      _emailController,
      _firstNameController,
      _lastNameController,
      _streetController,
      _apartmentController,
      _cityController,
      _regionController,
      _postalCodeController,
      _phoneController,
      _notesController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _emailFocus,
      _firstNameFocus,
      _lastNameFocus,
      _streetFocus,
      _cityFocus,
    ]) {
      f.dispose();
    }
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
    _selectedCountry = draft.billing.country.isNotEmpty
        ? draft.billing.country
        : 'US';
    _paymentPreference = draft.paymentPreference.isNotEmpty
        ? draft.paymentPreference
        : 'stripe';
  }

  String? _required(String? v, String message) =>
      v == null || v.trim().isEmpty ? message : null;

  String? _validateEmail(String? v) => v == null || !v.trim().contains('@')
      ? 'Enter a valid billing email'
      : null;

  bool get _billingIsValid =>
      _validateEmail(_emailController.text) == null &&
      [
        _firstNameController,
        _lastNameController,
        _streetController,
        _cityController,
      ].every((controller) => controller.text.trim().isNotEmpty);

  /// Focuses the first field that fails validation so it scrolls into view.
  void _focusFirstError() {
    final checks = <(FocusNode, String?)>[
      (_emailFocus, _validateEmail(_emailController.text)),
      (_firstNameFocus, _required(_firstNameController.text, 'x')),
      (_lastNameFocus, _required(_lastNameController.text, 'x')),
      (_streetFocus, _required(_streetController.text, 'x')),
      (_cityFocus, _required(_cityController.text, 'x')),
    ];
    for (final (node, error) in checks) {
      if (error != null) {
        node.requestFocus();
        return;
      }
    }
  }

  void _changeStep(int step) {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    setState(() => _step = step);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _continue() {
    if (_step == 0 &&
        (!_formKey.currentState!.validate() || !_billingIsValid)) {
      HapticFeedback.heavyImpact();
      _focusFirstError();
      return;
    }
    _changeStep(_step + 1);
  }

  Future<void> _submitCheckout() async {
    if (!_billingIsValid) {
      _changeStep(0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _formKey.currentState?.validate();
        _focusFirstError();
      });
      return;
    }
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      _focusFirstError();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please complete the highlighted fields.'),
          ),
        );
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

    final success = await ref
        .read(checkoutProvider.notifier)
        .saveDraft(
          billing: billing,
          notes: _notesController.text.trim(),
          paymentPreference: _paymentPreference,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      HapticFeedback.lightImpact();
      TextInput.finishAutofillContext();
      await showNoticeDialog(
        context,
        title: 'Order draft saved',
        message:
            'Your placement configuration and billing details have been stored. A private 7-day reservation has been created for your order.',
        buttonLabel: 'Back to cart',
      );
      if (mounted) context.go('/cart');
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              "We couldn't save your draft. Please check your details and try again.",
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = ref.watch(
      authStateProvider.select((s) => s.isAuthenticated),
    );
    final checkoutAsync = ref.watch(checkoutProvider);

    if (!authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Sign in to check out',
          message:
              'Sign in to your customer account to review your placement briefs and confirm billing details.',
          actionLabel: 'Sign in',
          onAction: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 1
              ? 'Payment method'
              : _step == 2
              ? 'Review order'
              : 'Checkout',
        ),
        leading: _step > 0
            ? IconButton(
                tooltip: 'Previous step',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _saving ? null : () => _changeStep(_step - 1),
              )
            : null,
      ),
      body: checkoutAsync.when(
        loading: () => const FormSkeleton(),
        error: (err, _) => ErrorState(
          error: err,
          onRetry: () => ref.read(checkoutProvider.notifier).loadCheckout(),
        ),
        data: (view) {
          _populateFromDraft(view.draft);
          final totalCents =
              view.cart.totalCents ??
              view.cart.items.fold<int>(
                0,
                (sum, i) => sum + (i.totalCents ?? 0),
              );

          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: context.pagePadding(top: AppSpace.sm),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StepProgress(
                            steps: ['Details', 'Payment', 'Review'],
                            current: _step,
                          ),
                          const SizedBox(height: AppSpace.xl),
                          if (_step == 2)
                            const InlineMessage(
                              tone: MessageTone.success,
                              icon: Icons.verified_user_outlined,
                              title: 'Save now. Confirm later.',
                              message:
                                  'No charges will be processed today. Your order details are saved privately for 7 days.',
                            ),
                          if (view.issues.isNotEmpty) ...[
                            const SizedBox(height: AppSpace.md),
                            InlineMessage(
                              tone: MessageTone.warning,
                              title: 'Please review',
                              message: view.issues.join('\n'),
                            ),
                          ],
                          const SizedBox(height: AppSpace.xl),
                          if (_step == 0) ...[
                            _FormSection(
                              icon: Icons.badge_outlined,
                              title: 'Billing contact',
                              children: [
                                AppTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  label: 'Billing email',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  autocorrect: false,
                                  validator: _validateEmail,
                                ),
                                _Pair(
                                  first: AppTextField(
                                    controller: _firstNameController,
                                    focusNode: _firstNameFocus,
                                    label: 'First name',
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.givenName,
                                    ],
                                    validator: (v) => _required(v, 'Required'),
                                  ),
                                  second: AppTextField(
                                    controller: _lastNameController,
                                    focusNode: _lastNameFocus,
                                    label: 'Last name',
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.familyName,
                                    ],
                                    validator: (v) => _required(v, 'Required'),
                                  ),
                                ),
                                AppTextField(
                                  controller: _phoneController,
                                  label: 'Phone (optional)',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.xl),
                            _FormSection(
                              icon: Icons.location_on_outlined,
                              title: 'Billing address',
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      _countries.any(
                                        (c) => c.code == _selectedCountry,
                                      )
                                      ? _selectedCountry
                                      : null,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Country',
                                    prefixIcon: Icon(
                                      Icons.public_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  items: [
                                    for (final c in _countries)
                                      DropdownMenuItem(
                                        value: c.code,
                                        child: Text(
                                          c.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: (val) => setState(
                                    () => _selectedCountry = val ?? 'US',
                                  ),
                                ),
                                AppTextField(
                                  controller: _streetController,
                                  focusNode: _streetFocus,
                                  label: 'Street address',
                                  textCapitalization: TextCapitalization.words,
                                  autofillHints: const [
                                    AutofillHints.streetAddressLine1,
                                  ],
                                  validator: (v) =>
                                      _required(v, 'Enter your street address'),
                                ),
                                AppTextField(
                                  controller: _apartmentController,
                                  label: 'Suite / apartment (optional)',
                                  textCapitalization: TextCapitalization.words,
                                  autofillHints: const [
                                    AutofillHints.streetAddressLine2,
                                  ],
                                ),
                                _Pair(
                                  first: AppTextField(
                                    controller: _cityController,
                                    focusNode: _cityFocus,
                                    label: 'City',
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.addressCity,
                                    ],
                                    validator: (v) => _required(v, 'Required'),
                                  ),
                                  second: AppTextField(
                                    controller: _regionController,
                                    label: 'State / region',
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.addressState,
                                    ],
                                  ),
                                ),
                                AppTextField(
                                  controller: _postalCodeController,
                                  label: 'Postal code (optional)',
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  autofillHints: const [
                                    AutofillHints.postalCode,
                                  ],
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.xl),
                          ],
                          if (_step == 1) ...[
                            _FormSection(
                              icon: Icons.payments_outlined,
                              title: 'Payment preference',
                              subtitle:
                                  'Choose a preference for your order draft. Payment details are collected when your order is confirmed.',
                              children: [
                                ChoiceTile(
                                  selected: _paymentPreference == 'stripe',
                                  leadingIcon: Icons.credit_card_rounded,
                                  title: 'Credit card',
                                  subtitle: 'Stripe',
                                  onTap: () => setState(
                                    () => _paymentPreference = 'stripe',
                                  ),
                                ),
                                ChoiceTile(
                                  selected: _paymentPreference == 'paypal',
                                  leadingIcon:
                                      Icons.account_balance_wallet_outlined,
                                  title: 'PayPal',
                                  subtitle: 'PayPal or account balance',
                                  onTap: () => setState(
                                    () => _paymentPreference = 'paypal',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.xl),
                            const InlineMessage(
                              icon: Icons.lock_outline_rounded,
                              message:
                                  'Your preference is saved with the draft. No payment is taken at this step.',
                            ),
                          ],
                          if (_step == 2) ...[
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Billing details',
                                          style: context.text.titleMedium,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _changeStep(0),
                                        child: const Text('Edit'),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_firstNameController.text} ${_lastNameController.text}',
                                    style: context.text.titleSmall,
                                  ),
                                  const SizedBox(height: AppSpace.xs),
                                  Text(
                                    _emailController.text,
                                    style: context.text.bodySmall,
                                  ),
                                  Text(
                                    '${_streetController.text}, ${_cityController.text}',
                                    style: context.text.bodySmall,
                                  ),
                                  const SizedBox(height: AppSpace.md),
                                  KeyValueRow(
                                    label: 'Payment preference',
                                    value: _paymentPreference == 'paypal'
                                        ? 'PayPal'
                                        : 'Credit card',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpace.xl),
                            _FormSection(
                              icon: Icons.sticky_note_2_outlined,
                              title: 'Campaign notes',
                              children: [
                                AppTextField(
                                  controller: _notesController,
                                  label: 'Notes (optional)',
                                  hint:
                                      'Timing, publication preferences, reference numbers…',
                                  minLines: 3,
                                  maxLines: 5,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.xl),
                            _OrderReview(view: view, totalCents: totalCents),
                          ],
                          const SizedBox(height: AppSpace.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PriceSummaryBar(
                label: 'Estimated total',
                cents: totalCents,
                actionLabel: _step == 0
                    ? 'Continue to payment'
                    : _step == 1
                    ? 'Review order'
                    : 'Save order draft',
                actionIcon: _step == 2
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                loading: _saving,
                onAction: _saving
                    ? null
                    : _step < 2
                    ? _continue
                    : _submitCheckout,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: p.brandText),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: context.text.titleLarge),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpace.xs),
          Text(
            subtitle!,
            style: context.text.bodySmall?.copyWith(color: p.textMuted),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpace.md),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Two fields side by side; stacks on narrow widths or large text.
class _Pair extends StatelessWidget {
  const _Pair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 300 || scale > 1.3) {
          return Column(
            children: [
              first,
              const SizedBox(height: AppSpace.md),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpace.md),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _OrderReview extends StatelessWidget {
  const _OrderReview({required this.view, required this.totalCents});

  final CheckoutView view;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = view.cart.items;
    return _FormSection(
      icon: Icons.receipt_long_outlined,
      title: 'Order review',
      children: [
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DomainAvatar(domain: item.domain ?? 'Publication', size: 36),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.cleanDomain(item.domain ?? 'Publication'),
                      style: context.text.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.writingWords == 0
                          ? 'Customer-provided article'
                          : '${item.writingWords}-word writing package',
                      style: context.text.bodySmall?.copyWith(
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Text(
                Formatters.formatCurrency(item.totalCents),
                style: context.text.titleSmall,
              ),
            ],
          ),
        Divider(height: 1, color: p.border),
        KeyValueRow(
          label: 'Estimated total',
          value: Formatters.formatCurrency(totalCents),
          emphasis: true,
        ),
      ],
    );
  }
}
