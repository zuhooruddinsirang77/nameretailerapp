import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(authStateProvider.notifier).clearMessages();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final success = await ref
        .read(authStateProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      HapticFeedback.lightImpact();
      TextInput.finishAutofillContext();
      await showNoticeDialog(
        context,
        title: 'Your account is ready',
        message:
            'You can now sign in to save placements, build briefs and review order drafts.',
        buttonLabel: 'Continue to sign in',
      );
      if (mounted) context.pushReplacement('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final busy = authState.status == AuthStatus.authenticating;

    return AuthScaffold(
      title: 'Create your account',
      subtitle:
          'Create a customer account to keep your placement plans and order drafts together.',
      errorTitle: "Couldn't create your account",
      errorMessage: authState.errorMessage,
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
            child: Text(
              'Already registered?',
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: busy ? null : () => context.pushReplacement('/login'),
            child: const Text('Sign in'),
          ),
        ],
      ),
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'Jane Doe',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email address',
                  hint: 'name@company.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  validator: (val) => val == null || !val.trim().contains('@')
                      ? 'Enter a valid email address'
                      : null,
                ),
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: 'Password',
                  helper: 'At least 6 characters',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => busy ? null : _register(),
                  validator: (val) => val == null || val.length < 6
                      ? 'Use at least 6 characters'
                      : null,
                ),
                const SizedBox(height: AppSpace.xl),
                AppButton(
                  label: 'Create account',
                  trailingIcon: Icons.arrow_forward_rounded,
                  loading: busy,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
