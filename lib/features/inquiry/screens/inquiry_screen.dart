import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/inquiry_repository.dart';

final inquiryRepositoryProvider = Provider<InquiryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InquiryRepository(apiClient: apiClient);
});

class InquiryScreen extends ConsumerStatefulWidget {
  const InquiryScreen({super.key, this.domain});

  final String? domain;

  @override
  ConsumerState<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends ConsumerState<InquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _domainController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _scrollController = ScrollController();

  bool _submitting = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.domain != null) {
      _domainController.text = widget.domain!;
    }
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _domainController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: AppMotion.of(context),
      curve: AppMotion.standard,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final repository = ref.read(inquiryRepositoryProvider);
      final msg = await repository.submitInquiry(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        domain: _domainController.text.trim(),
        message: _messageController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _submitting = false;
        _successMessage = msg;
        _messageController.clear();
      });
      HapticFeedback.lightImpact();
      _scrollToTop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = describeError(e).message;
      });
      _scrollToTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Placement inquiry')),
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: context.pagePadding(top: AppSpace.sm),
            children: [
              const ScreenIntro(
                icon: Icons.support_agent_rounded,
                eyebrow: 'Publisher support',
                title: 'Let’s find the right fit.',
                message:
                    'Ask about a publication, a custom niche or your next campaign.',
              ),
              const SizedBox(height: AppSpace.lg),
              MotionSize(
                duration: AppMotion.of(context, AppMotion.fast),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.lg),
                        child: InlineMessage(
                          tone: MessageTone.success,
                          title: 'Inquiry sent',
                          message: _successMessage!,
                        ),
                      ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.lg),
                        child: InlineMessage(
                          tone: MessageTone.danger,
                          title: "Couldn't send your inquiry",
                          message: _errorMessage!,
                        ),
                      ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Your inquiry', style: context.text.titleMedium),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      controller: _nameController,
                      label: 'Your name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      validator: (v) => v == null || !v.trim().contains('@')
                          ? 'Enter a valid email address'
                          : null,
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppTextField(
                      controller: _domainController,
                      label: 'Domain of interest (optional)',
                      hint: 'e.g. example.com',
                      icon: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone (optional)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppTextField(
                      controller: _messageController,
                      label: 'How can we help?',
                      hint:
                          'Your topic, content format or turnaround expectations…',
                      minLines: 4,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => v == null || v.trim().length < 5
                          ? 'Please share a little more detail'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              AppButton(
                label: 'Send inquiry',
                icon: Icons.send_rounded,
                loading: _submitting,
                size: AppButtonSize.large,
                expand: true,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpace.lg),
              Center(
                child: Text(
                  'Or email info@nameretailer.com',
                  style: context.text.bodySmall?.copyWith(color: p.textMuted),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],
          ),
        ),
      ),
    );
  }
}
