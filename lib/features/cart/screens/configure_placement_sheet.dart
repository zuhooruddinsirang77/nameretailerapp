import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../marketplace/models/placement_options.dart';
import '../../marketplace/models/product.dart';
import '../../marketplace/providers/product_provider.dart';
import '../data/article_repository.dart';
import '../models/article_file.dart';
import '../models/brief_validation.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';
import '../widgets/article_toolbar.dart';

Future<void> showPlacementSheet(
  BuildContext context,
  Product product, {
  PlacementOptions? options,
}) => showAppSheetRaw<void>(
  context,
  isDismissible: false,
  builder: (_) => ConfigurePlacementSheet(product: product, options: options),
);

class ConfigurePlacementSheet extends ConsumerStatefulWidget {
  const ConfigurePlacementSheet({
    super.key,
    required this.product,
    this.options,
  });
  final Product product;
  final PlacementOptions? options;
  @override
  ConsumerState<ConfigurePlacementSheet> createState() =>
      _ConfigurePlacementSheetState();
}

class _ConfigurePlacementSheetState
    extends ConsumerState<ConfigurePlacementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _url = TextEditingController(), _keyword = TextEditingController();
  final _requirements = TextEditingController(),
      _article = TextEditingController();
  final _articleFocus = FocusNode();
  PlacementOptions? _options;
  ArticleFile? _file;
  List<ArticleFile> _files = [];
  int _words = 0;
  bool _loading = true, _busy = false, _uploadMode = false, _restored = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    for (final controller in [_url, _keyword, _requirements, _article]) {
      controller.dispose();
    }
    _articleFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final options = await ref
          .read(productRepositoryProvider)
          .getProductOptions(widget.product.id);
      if (!mounted) return;
      if (ref.read(authStateProvider).isAuthenticated) {
        await ref.read(cartProvider.notifier).loadCart();
        if (!mounted) return;
        final saved = ref
            .read(cartProvider)
            .valueOrNull
            ?.items
            .where((item) => item.productId == widget.product.id)
            .firstOrNull;
        if (!_restored && saved != null) {
          _words = saved.writingWords;
          _url.text = saved.brief?.promotedUrl ?? '';
          _keyword.text = saved.brief?.keyword ?? '';
          _requirements.text = saved.brief?.specialRequirements ?? '';
          _article.text = saved.brief?.articleText ?? '';
          _file = saved.file;
          _uploadMode = saved.brief?.fileId != null;
          _restored = true;
          if (_uploadMode && _file == null) {
            _error =
                'Your article file expired or is unavailable. Upload it again.';
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _options = options;
        _loading = false;
      });
      if (ref.read(authStateProvider).isAuthenticated) {
        try {
          final files = await ref.read(articleRepositoryProvider).list();
          if (mounted) {
            setState(
              () => _files = files.where((file) => file.available).toList(),
            );
          }
        } catch (error) {
          if (mounted) setState(() => _error = error.toString());
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  int get _writingCents =>
      _options?.writingOptions
          .where((option) => option.words == _words)
          .firstOrNull
          ?.priceCents ??
      0;
  int get _total => (_options?.placementCents ?? 0) + _writingCents;
  Future<void> _signIn() async {
    await context.push('/login');
    if (mounted && ref.read(authStateProvider).isAuthenticated) await _load();
  }

  Future<void> _upload() async {
    if (!ref.read(authStateProvider).isAuthenticated) {
      await _signIn();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final chosen = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (chosen == null || !mounted) return;
      final size = await chosen.length();
      if (size == null || size == 0 || size > 5 * 1024 * 1024) {
        throw Exception('Choose a nonempty article file up to 5 MiB.');
      }
      final bytes = await chosen.readAsBytes();
      if (!mounted) return;
      final uploaded = await ref
          .read(articleRepositoryProvider)
          .upload(chosen.name, bytes);
      if (mounted) {
        setState(() {
          _file = uploaded;
          _files = [uploaded, ..._files];
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeFile() async {
    final file = _file;
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(articleRepositoryProvider).remove(file.id);
      if (mounted) {
        setState(() {
          _file = null;
          _files.removeWhere((value) => value.id == file.id);
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadFile() async {
    final file = _file;
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = await ref.read(articleRepositoryProvider).download(file.id);
      if (!mounted) return;
      await FilePicker.saveFile(fileName: file.name, bytes: bytes);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!ref.read(authStateProvider).isAuthenticated) {
      await _signIn();
      return;
    }
    final options = _options;
    if (options == null || !_formKey.currentState!.validate()) return;
    if (_words != 0 &&
        !options.writingOptions.any((value) => value.words == _words)) {
      setState(
        () => _error =
            'This writing package is unavailable. Choose a current option.',
      );
      return;
    }
    if (_words == 0 && _file != null && !_file!.available) {
      setState(() => _error = 'Your article file expired. Upload it again.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final item = CartItem(
      productId: options.productId,
      productVersion: options.productVersion,
      writingWords: _words,
      domain: options.domain,
      placementCents: options.placementCents,
      writingCents: _writingCents,
      totalCents: _total,
      options: options,
      brief: PlacementBrief(
        promotedUrl: _url.text.trim(),
        keyword: _keyword.text.trim(),
        specialRequirements: _requirements.text.trim(),
        articleText: _article.text.trim(),
        fileId: _words == 0 ? _file?.id : null,
      ),
    );
    final notifier = ref.read(cartProvider.notifier);
    final success = await notifier.saveItem(item);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!success) {
      final error = notifier.lastError;
      _restored = true;
      await _load();
      if (mounted) {
        setState(
          () => _error =
              error ?? 'Review the current prices and try saving again.',
        );
      }
      return;
    }
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(
      authStateProvider.select((state) => state.isAuthenticated),
    );
    final options = _options;
    return PopScope(
      canPop: !_busy,
      child: AppSheetFrame(
        title: 'Create a placement brief',
        subtitle: Formatters.cleanDomain(widget.product.domain),
        footer: options == null
            ? null
            : PriceActionRow(
                label: 'Total (USD)',
                cents: _total,
                caption:
                    '${Formatters.formatCurrency(options.placementCents)} placement + ${Formatters.formatCurrency(_writingCents)} writing',
                actionLabel: signedIn
                    ? 'Save placement'
                    : 'Sign in to save',
                actionIcon: Icons.arrow_forward_rounded,
                loading: _busy,
                onAction: _loading || _busy ? null : _save,
              ),
        child: _loading
            ? const SizedBox(height: 280, child: FormSkeleton())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    InlineMessage(tone: MessageTone.danger, message: _error!),
                    TextButton(
                      onPressed: _busy ? null : _load,
                      child: const Text('Refresh publication'),
                    ),
                    const SizedBox(height: AppSpace.md),
                  ],
                  if (options != null)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const InlineMessage(
                            title: 'How it works',
                            message:
                                '1. Share your destination URL and keyword.\n2. Add your article or choose a writing package.\n3. Review the publication requirements.\n4. Save your brief and continue to review.',
                          ),
                          const SizedBox(height: AppSpace.lg),
                          const SectionHeader(
                            title: 'Your selected publication',
                          ),
                          const SizedBox(height: AppSpace.sm),
                          AppCard(
                            child: Column(
                              children: [
                                KeyValueRow(
                                  label: 'Placement price',
                                  value: Formatters.formatCurrency(
                                    options.placementCents,
                                  ),
                                ),
                                KeyValueRow(
                                  label: 'Link type',
                                  value: options.linkType.isEmpty
                                      ? 'Not supplied'
                                      : options.linkType,
                                ),
                                KeyValueRow(
                                  label: 'Turnaround',
                                  value: options.turnaround.isEmpty
                                      ? 'Not supplied'
                                      : options.turnaround,
                                ),
                                const SizedBox(height: AppSpace.sm),
                                InlineMessage(
                                  message: options.requirements.isEmpty
                                      ? 'No additional publisher requirements were supplied. Please confirm placement scope before purchase.'
                                      : options.requirements,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.lg),
                          const SectionHeader(
                            title: 'Create your placement brief',
                          ),
                          const SizedBox(height: AppSpace.md),
                          AppTextField(
                            controller: _url,
                            label: 'Promoted URL *',
                            hint: 'https://your-site.com/page/',
                            icon: Icons.link,
                            enabled: !_busy,
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            maxLength: 2048,
                            validator: validatePromotedUrl,
                          ),
                          const SizedBox(height: AppSpace.md),
                          AppTextField(
                            controller: _keyword,
                            label: 'Keyword or anchor text *',
                            hint: 'e.g. best productivity tools',
                            enabled: !_busy,
                            maxLength: 200,
                            validator: (value) => validateBriefText(
                              value,
                              max: 200,
                              required: true,
                            ),
                          ),
                          const SizedBox(height: AppSpace.md),
                          AppTextField(
                            controller: _requirements,
                            label: 'Special requirements (optional)',
                            hint:
                                'Suggested title, audience, tone and placement constraints...',
                            enabled: !_busy,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 4000,
                            validator: (value) =>
                                validateBriefText(value, max: 4000),
                          ),
                          const SizedBox(height: AppSpace.lg),
                          const SectionHeader(title: 'Select pricing option'),
                          const SizedBox(height: AppSpace.md),
                          IgnorePointer(
                            ignoring: _busy,
                            child: Column(
                              children: [
                                ChoiceTile(
                                  selected: _words == 0,
                                  title: 'Link only',
                                  subtitle: 'Supply your own article.',
                                  trailing: Text(
                                    Formatters.formatCurrency(
                                      options.placementCents,
                                    ),
                                  ),
                                  onTap: () => setState(() => _words = 0),
                                ),
                                const SizedBox(height: AppSpace.sm),
                                if (options.writingOptions.isNotEmpty)
                                  ChoiceTile(
                                    selected: _words != 0,
                                    title: 'Link + article',
                                    subtitle:
                                        'Placement plus the allocated writing charge.',
                                    trailing: Text(
                                      _words != 0
                                          ? Formatters.formatCurrency(_total)
                                          : 'From ${Formatters.formatCurrency(options.placementCents + options.writingOptions.map((value) => value.priceCents).reduce((a, b) => a < b ? a : b))}',
                                    ),
                                    onTap: () => setState(
                                      () => _words =
                                          options.writingOptions.first.words,
                                    ),
                                  )
                                else
                                  const InlineMessage(
                                    message:
                                        'Article writing is unavailable for this publication.',
                                  ),
                              ],
                            ),
                          ),
                          if (_words != 0) ...[
                            const SizedBox(height: AppSpace.md),
                            DropdownButtonFormField<int>(
                              key: ValueKey('words-$_words'),
                              initialValue:
                                  options.writingOptions.any(
                                    (value) => value.words == _words,
                                  )
                                  ? _words
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Content length',
                              ),
                              items: options.writingOptions
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value.words,
                                      child: Text(
                                        '${value.words} words (+${Formatters.formatCurrency(value.priceCents)})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _busy
                                  ? null
                                  : (value) =>
                                        setState(() => _words = value ?? 0),
                              validator: (value) => value == null
                                  ? 'Choose an available writing package.'
                                  : null,
                            ),
                          ],
                          const SizedBox(height: AppSpace.lg),
                          SectionHeader(
                            title: _words == 0
                                ? 'Your article'
                                : 'Article brief / theme suggestions',
                          ),
                          if (_words == 0)
                            Wrap(
                              spacing: AppSpace.sm,
                              children: [
                                ChoiceChip(
                                  label: const Text('Paste your article'),
                                  selected: !_uploadMode,
                                  onSelected: _busy
                                      ? null
                                      : (_) =>
                                            setState(() => _uploadMode = false),
                                ),
                                ChoiceChip(
                                  label: const Text('Upload file'),
                                  selected: _uploadMode,
                                  onSelected: _busy
                                      ? null
                                      : (_) =>
                                            setState(() => _uploadMode = true),
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpace.md),
                          if (!_uploadMode || _words != 0) ...[
                            ArticleToolbar(
                              controller: _article,
                              focusNode: _articleFocus,
                              enabled: !_busy,
                            ),
                            AppTextField(
                              controller: _article,
                              focusNode: _articleFocus,
                              enabled: !_busy,
                              label: _words == 0
                                  ? 'Article text'
                                  : 'Article brief *',
                              hint: _words == 0
                                  ? 'Paste your article here, or upload a file below...'
                                  : 'Describe the topic, structure, audience and points the writer should cover.',
                              minLines: 5,
                              maxLines: 10,
                              maxLength: 40000,
                              validator: (value) => validateBriefText(
                                value,
                                max: 40000,
                                required:
                                    _words != 0 || !(_file?.available ?? false),
                              ),
                            ),
                            const Text(
                              'Use the toolbar to format your text. Upload a document to keep its original styling.',
                            ),
                          ],
                          if (_words == 0) ...[
                            const SizedBox(height: AppSpace.md),
                            FormField<bool>(
                              validator: (_) =>
                                  _article.text.trim().isEmpty &&
                                      !(_file?.available ?? false)
                                  ? 'Paste your article or upload an available file.'
                                  : null,
                              builder: (field) => AppCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Or upload article (instead of pasted text)',
                                    ),
                                    const SizedBox(height: AppSpace.sm),
                                    AppButton(
                                      label: signedIn
                                          ? 'Choose file'
                                          : 'Sign in to upload',
                                      icon: Icons.upload_file,
                                      onPressed: _busy ? null : _upload,
                                      variant: AppButtonVariant.outline,
                                    ),
                                    const Text(
                                      'PDF, DOC, DOCX or TXT up to 5 MiB. Files are private, expire after 7 days and are not malware-scanned.',
                                    ),
                                    if (_files.isNotEmpty)
                                      DropdownButtonFormField<String>(
                                        key: ValueKey(
                                          'file-${_file?.id}-${_files.length}',
                                        ),
                                        initialValue:
                                            _files.any(
                                              (value) => value.id == _file?.id,
                                            )
                                            ? _file?.id
                                            : null,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Reuse a retained article',
                                        ),
                                        items: _files
                                            .map(
                                              (value) => DropdownMenuItem(
                                                value: value.id,
                                                child: Text(
                                                  value.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: _busy
                                            ? null
                                            : (id) => setState(
                                                () => _file = _files
                                                    .where(
                                                      (value) => value.id == id,
                                                    )
                                                    .firstOrNull,
                                              ),
                                      ),
                                    if (_file != null) ...[
                                      Text('Selected: ${_file!.name}'),
                                      TextButton(
                                        onPressed: _busy ? null : _downloadFile,
                                        child: const Text(
                                          'Download article file',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _busy ? null : _removeFile,
                                        child: const Text(
                                          'Delete article file',
                                        ),
                                      ),
                                    ],
                                    if (field.hasError)
                                      InlineMessage(
                                        tone: MessageTone.danger,
                                        message: field.errorText!,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpace.lg),
                          const InlineMessage(
                            title: 'Before you continue',
                            message:
                                'Saving a brief does not reserve inventory, place an order or charge a payment. Paid-in-kind disclosures must be agreed before publication.',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
