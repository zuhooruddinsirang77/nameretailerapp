import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../data/product_repository.dart';
import '../models/facets.dart';

class FilterSheet extends StatefulWidget {
  final ProductFilterParams initialParams;
  final ProductFacets facets;
  final Function(ProductFilterParams) onApply;

  const FilterSheet({
    super.key,
    required this.initialParams,
    required this.facets,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _selectedCategory;
  late String? _selectedCountry;
  late double _minDr;
  late double _minDa;
  late double _maxPrice;

  final List<String> _popularCategories = const [
    'Business',
    'Technology',
    'Marketing',
    'Finance',
    'Health',
    'E-commerce',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialParams.category;
    _selectedCountry = widget.initialParams.country;
    _minDr = (widget.initialParams.minDr ?? 0).toDouble();
    _minDa = (widget.initialParams.minDa ?? 0).toDouble();
    _maxPrice = widget.initialParams.maxPrice ?? 1000;
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _selectedCountry = null;
      _minDr = 0;
      _minDa = 0;
      _maxPrice = 1000;
    });
  }

  void _apply() {
    final updated = widget.initialParams.copyWith(
      category: _selectedCategory,
      country: _selectedCountry,
      minDr: _minDr > 0 ? _minDr.toInt() : null,
      minDa: _minDa > 0 ? _minDa.toInt() : null,
      maxPrice: _maxPrice < 1000 ? _maxPrice : null,
      page: 1,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      padding: EdgeInsets.only(
        top: AppDimens.space16,
        left: AppDimens.space20,
        right: AppDimens.space20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.cardBorderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 20, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Catalog Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Topic Chips
            Text(
              'Popular Topics',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? cat : null;
                    });
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimaryLight),
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.surfaceDarkCard : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // All Topics Dropdown
            Text(
              'All Topics',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory != null && widget.facets.categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : null,
              decoration: InputDecoration(
                hintText: 'Select publication niche',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDarkCard : const Color(0xFFF8FAFC),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Niches & Categories'),
                ),
                ...widget.facets.categories.map(
                  (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                ),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),

            // Country / Region Dropdown
            Text(
              'Target Region / Country',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCountry != null && widget.facets.countries.contains(_selectedCountry)
                  ? _selectedCountry
                  : null,
              decoration: InputDecoration(
                hintText: 'Select country',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDarkCard : const Color(0xFFF8FAFC),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Worldwide (All Countries)'),
                ),
                ...widget.facets.countries.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                ),
              ],
              onChanged: (val) => setState(() => _selectedCountry = val),
            ),
            const SizedBox(height: 20),

            // Minimum DR Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minimum Domain Rating (DR)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.metricDr.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _minDr > 0 ? 'DR ${_minDr.toInt()}+' : 'Any DR',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.metricDr,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _minDr,
              min: 0,
              max: 90,
              divisions: 18,
              activeColor: AppColors.metricDr,
              onChanged: (val) => setState(() => _minDr = val),
            ),
            const SizedBox(height: 10),

            // Minimum DA Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minimum Domain Authority (DA)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.metricDa.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _minDa > 0 ? 'DA ${_minDa.toInt()}+' : 'Any DA',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.metricDa,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _minDa,
              min: 0,
              max: 90,
              divisions: 18,
              activeColor: AppColors.metricDa,
              onChanged: (val) => setState(() => _minDa = val),
            ),
            const SizedBox(height: 10),

            // Max Price Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maximum Placement Price',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _maxPrice < 1000 ? 'Under \$${_maxPrice.toInt()}' : 'No Limit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentEmerald,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxPrice,
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppColors.accentEmerald,
              onChanged: (val) => setState(() => _maxPrice = val),
            ),
            const SizedBox(height: 20),

            // Apply CTA Button
            AppButton(
              text: 'Apply Filters',
              onPressed: _apply,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.large,
              isFullWidth: true,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}
