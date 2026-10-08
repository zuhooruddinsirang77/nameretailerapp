import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Don't show a stale error from a previous attempt on another screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(authStateProvider.notifier).clearMessages();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final success = await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (success && mounted) {
      HapticFeedback.lightImpact();
      TextInput.finishAutofillContext();
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/marketplace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final busy = authState.status == AuthStatus.authenticating;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Your placements, briefs and order drafts, in one place.',
      errorTitle: "Couldn't sign you in",
      errorMessage: authState.errorMessage,
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
            child: Text(
              'New to NameRetailer?',
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: busy ? null : () => context.pushReplacement('/register'),
            child: const Text('Create an account'),
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
                  controller: _emailController,
                  label: 'Email address',
                  hint: 'name@company.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  validator: (val) => val == null || !val.trim().contains('@')
                      ? 'Enter the email you registered with'
                      : null,
                ),
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => busy ? null : _login(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter your password' : null,
                ),
                const SizedBox(height: AppSpace.xl),
                AppButton(
                  label: 'Sign in',
                  trailingIcon: Icons.arrow_forward_rounded,
                  loading: busy,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
