import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/product_repository.dart';
import '../models/facets.dart';
import 'filter_edit.dart';

/// Opens the catalogue filter sheet. [onApply] receives the updated params
/// (page reset to 1).
Future<void> showFilterSheet(
  BuildContext context, {
  required ProductFilterParams initial,
  required ProductFacets facets,
  required ValueChanged<ProductFilterParams> onApply,
}) {
  return showAppSheetRaw<void>(
    context,
    builder: (_) =>
        FilterSheet(initialParams: initial, facets: facets, onApply: onApply),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.initialParams,
    required this.facets,
    required this.onApply,
  });

  final ProductFilterParams initialParams;
  final ProductFacets facets;
  final ValueChanged<ProductFilterParams> onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const _drDaMax = 100.0;
  static const _priceMax = 1000.0;

  static const _popularCategories = [
    'Business',
    'Technology',
    'Marketing',
    'Finance',
    'Health',
    'E-commerce',
  ];

  String? _category;
  String? _country;
  late RangeValues _dr;
  late RangeValues _da;
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    final p = widget.initialParams;
    _category = p.category;
    _country = p.country;
    _dr = RangeValues(
      (p.minDr ?? 0).toDouble(),
      (p.maxDr ?? _drDaMax).toDouble(),
    );
    _da = RangeValues(
      (p.minDa ?? 0).toDouble(),
      (p.maxDa ?? _drDaMax).toDouble(),
    );
    _price = RangeValues(p.minPrice ?? 0, p.maxPrice ?? _priceMax);
  }

  bool get _isDefault =>
      _category == null &&
      _country == null &&
      _dr == const RangeValues(0, _drDaMax) &&
      _da == const RangeValues(0, _drDaMax) &&
      _price == const RangeValues(0, _priceMax);

  void _reset() {
    setState(() {
      _category = null;
      _country = null;
      _dr = const RangeValues(0, _drDaMax);
      _da = const RangeValues(0, _drDaMax);
      _price = const RangeValues(0, _priceMax);
    });
  }

  void _apply() {
    HapticFeedback.lightImpact();
    widget.onApply(
      widget.initialParams.edit(
        category: _category,
        country: _country,
        minDr: _dr.start > 0 ? _dr.start.round() : null,
        maxDr: _dr.end < _drDaMax ? _dr.end.round() : null,
        minDa: _da.start > 0 ? _da.start.round() : null,
        maxDa: _da.end < _drDaMax ? _da.end.round() : null,
        minPrice: _price.start > 0 ? _price.start : null,
        maxPrice: _price.end < _priceMax ? _price.end : null,
        page: 1,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final facets = widget.facets;

    return AppSheetFrame(
      title: 'Filters',
      subtitle: 'Narrow the catalogue to publications that fit',
      headerAction: TextButton(
        onPressed: _isDefault ? null : _reset,
        child: const Text('Reset'),
      ),
      footer: AppButton(
        label: 'Show results',
        icon: Icons.check_rounded,
        size: AppButtonSize.large,
        expand: true,
        onPressed: _apply,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Audience fit',
            subtitle: 'Topic and location',
          ),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final cat in _popularCategories)
                FilterChip(
                  label: Text(cat),
                  selected: _category == cat,
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  selectedColor: p.brandSoft,
                  side: BorderSide(
                    color: _category == cat ? p.brand : p.borderStrong,
                    width: _category == cat ? 1.5 : 1,
                  ),
                  labelStyle: context.text.labelMedium?.copyWith(
                    color: _category == cat ? p.brandText : p.text,
                  ),
                  onSelected: (v) => setState(() => _category = v ? cat : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          _PickerField(
            label: 'All topics',
            value: _category,
            emptyLabel: 'Any topic',
            icon: Icons.category_outlined,
            onTap: () async {
              final picked = await showOptionPicker(
                context,
                title: 'Topic',
                options: facets.categories,
                selected: _category,
                anyLabel: 'Any topic',
              );
              if (picked != null) setState(() => _category = picked.value);
            },
          ),
          const SizedBox(height: AppSpace.sm),
          _PickerField(
            label: 'Country',
            value: _country,
            emptyLabel: 'Worldwide',
            icon: Icons.public_rounded,
            onTap: () async {
              final picked = await showOptionPicker(
                context,
                title: 'Country',
                options: facets.countries,
                selected: _country,
                anyLabel: 'Worldwide',
              );
              if (picked != null) setState(() => _country = picked.value);
            },
          ),
          const SizedBox(height: AppSpace.xl),
          _RangeBlock(
            title: 'Domain Rating (DR)',
            summary: _summary(_dr, 'DR', _drDaMax),
            color: p.metricDr,
            values: _dr,
            max: _drDaMax,
            divisions: 20,
            onChanged: (v) => setState(() => _dr = v),
          ),
          const SizedBox(height: AppSpace.lg),
          _RangeBlock(
            title: 'Domain Authority (DA)',
            summary: _summary(_da, 'DA', _drDaMax),
            color: p.metricDa,
            values: _da,
            max: _drDaMax,
            divisions: 20,
            onChanged: (v) => setState(() => _da = v),
          ),
          const SizedBox(height: AppSpace.lg),
          _RangeBlock(
            title: 'Placement price',
            summary: _priceSummary(),
            color: p.price,
            values: _price,
            max: _priceMax,
            divisions: 20,
            labelBuilder: (v) => '\$${v.round()}',
            onChanged: (v) => setState(() => _price = v),
          ),
        ],
      ),
    );
  }

  String _summary(RangeValues v, String name, double max) {
    if (v.start <= 0 && v.end >= max) return 'Any $name';
    if (v.start <= 0) return '$name up to ${v.end.round()}';
    if (v.end >= max) return '$name ${v.start.round()}+';
    return '$name ${v.start.round()}–${v.end.round()}';
  }

  String _priceSummary() {
    if (_price.start <= 0 && _price.end >= _priceMax) return 'Any price';
    if (_price.start <= 0) return 'Up to \$${_price.end.round()}';
    if (_price.end >= _priceMax) return '\$${_price.start.round()}+';
    return '\$${_price.start.round()} – \$${_price.end.round()}';
  }
}

class _RangeBlock extends StatelessWidget {
  const _RangeBlock({
    required this.title,
    required this.summary,
    required this.color,
    required this.values,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.labelBuilder,
  });

  final String title;
  final String summary;
  final Color color;
  final RangeValues values;
  final double max;
  final int divisions;
  final ValueChanged<RangeValues> onChanged;
  final String Function(double)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            Text(title, style: context.text.titleSmall),
            const SizedBox(width: AppSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: p.tint(color),
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                summary,
                style: context.text.labelMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
            valueIndicatorColor: color,
          ),
          child: RangeSlider(
            values: values,
            min: 0,
            max: max,
            divisions: divisions,
            labels: RangeLabels(
              labelBuilder?.call(values.start) ??
                  values.start.round().toString(),
              labelBuilder?.call(values.end) ?? values.end.round().toString(),
            ),
            semanticFormatterCallback: (v) =>
                labelBuilder?.call(v) ?? v.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.emptyLabel,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String emptyLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: '$label: ${value ?? emptyLabel}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: BorderSide(color: p.borderStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpace.minTarget + 8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: p.textMuted),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: context.text.labelSmall?.copyWith(
                            color: p.textMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          value ?? emptyLabel,
                          style: context.text.bodyLarge?.copyWith(
                            color: value == null ? p.textSecondary : p.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.unfold_more_rounded, color: p.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Result of [showOptionPicker]; `value == null` means "any".
class PickedOption {
  const PickedOption(this.value);
  final String? value;
}

/// Searchable single-choice picker for long lists (countries, topics).
Future<PickedOption?> showOptionPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String? selected,
  required String anyLabel,
}) {
  return showAppSheetRaw<PickedOption>(
    context,
    builder: (_) => _OptionPicker(
      title: title,
      options: options,
      selected: selected,
      anyLabel: anyLabel,
    ),
  );
}

class _OptionPicker extends StatefulWidget {
  const _OptionPicker({
    required this.title,
    required this.options,
    required this.selected,
    required this.anyLabel,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final String anyLabel;

  @override
  State<_OptionPicker> createState() => _OptionPickerState();
}

class _OptionPickerState extends State<_OptionPicker> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final q = _q.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();
    final height = MediaQuery.sizeOf(context).height * 0.6;

    Widget row(String label, String? value, bool isSelected) => ListTile(
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: context.text.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? p.brandText : p.text,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: p.brandText)
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop(PickedOption(value));
      },
    );

    return AppSheetFrame(
      title: widget.title,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            AppSearchField(
              controller: _search,
              hint: 'Search',
              onChanged: (v) => setState(() => _q = v),
              onClear: () => setState(() => _q = ''),
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: ListView.builder(
                itemCount: shown.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return row(widget.anyLabel, null, widget.selected == null);
                  }
                  final o = shown[i - 1];
                  return row(o, o, widget.selected == o);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
