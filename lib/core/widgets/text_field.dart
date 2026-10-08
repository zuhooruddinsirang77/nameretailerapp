import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// Form field with the app's look. Uses a floating label (native a11y
/// behaviour, scales with text size) and validates as the user interacts.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.icon,
    this.suffix,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autovalidate = true,
    this.autocorrect = true,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final Widget? suffix;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autovalidate;
  final bool autocorrect;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final multiline = widget.maxLines != 1;
    Widget? suffix = widget.suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: widget.isPassword && _obscured,
      keyboardType:
          widget.keyboardType ??
          (multiline ? TextInputType.multiline : TextInputType.text),
      textInputAction:
          widget.textInputAction ??
          (multiline ? TextInputAction.newline : TextInputAction.next),
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autocorrect: widget.isPassword ? false : widget.autocorrect,
      enableSuggestions: !widget.isPassword,
      scrollPadding: const EdgeInsets.all(AppSpace.xxl * 3),
      autovalidateMode: widget.autovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        helperMaxLines: 2,
        alignLabelWithHint: multiline,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Native search well used on Home, the catalogue and option pickers.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.trailing,
    this.fillColor,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final Widget? trailing;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.inputDecorationTheme;
    OutlineInputBorder pill(
      InputBorder? source, {
      double? width,
      Color? color,
    }) {
      final side = source is OutlineInputBorder
          ? source.borderSide
          : const BorderSide();
      return OutlineInputBorder(
        borderRadius: AppRadius.brPill,
        borderSide: side.copyWith(
          width: width ?? side.width,
          color: color ?? side.color,
        ),
      );
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        scrollPadding: const EdgeInsets.all(AppSpace.xxl * 3),
        decoration: InputDecoration(
          hintText: hint,
          fillColor: fillColor,
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon:
              trailing ??
              (value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        controller.clear();
                        onClear?.call();
                      },
                    )),
          border: pill(base.border),
          enabledBorder: pill(base.enabledBorder),
          focusedBorder: pill(base.focusedBorder),
        ),
      ),
    );
  }
}
