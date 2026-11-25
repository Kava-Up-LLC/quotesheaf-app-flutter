import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class QfSearchField extends StatelessWidget {
  const QfSearchField({super.key, required this.hint, required this.onChanged, this.controller});

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.tap,
      margin: const EdgeInsets.fromLTRB(AppSpacing.sideDock, 14, AppSpacing.sideDock, 0),
      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppSpacing.radiusField)),
      child: Row(children: [
        const SizedBox(width: 14),
        const Icon(LucideIcons.search, size: 18, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppText.body.copyWith(fontWeight: FontWeight.w400),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppText.body.copyWith(fontWeight: FontWeight.w400, color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ]),
    );
  }
}

class QfFilterChips<T> extends StatelessWidget {
  const QfFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        for (final o in options)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () => onSelected(o),
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
              child: Container(
                height: AppSpacing.tap,
                alignment: Alignment.center,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o == selected ? AppColors.tint : null,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  ),
                  child: Text(labelOf(o),
                      style: AppText.captionStrong.copyWith(color: o == selected ? AppColors.ink : AppColors.muted)),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Labelled text field: label above, 48h input, hint/error below.
class QfTextField extends StatelessWidget {
  const QfTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.hint,
    this.error,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusField), borderSide: BorderSide(color: c));
    final hasError = error != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.captionStrong),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: 1,
        textCapitalization: textCapitalization,
        style: AppText.body.copyWith(fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppText.body.copyWith(fontWeight: FontWeight.w400, color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          isDense: true,
          enabledBorder: border(hasError ? AppColors.error : AppColors.hairline),
          focusedBorder: border(hasError ? AppColors.error : AppColors.ink),
        ),
      ),
      if (hasError || hint != null) ...[
        const SizedBox(height: 5),
        Text(error ?? hint!, style: hasError ? AppText.error : AppText.micro),
      ],
    ]);
  }
}

/// − value + stepper (46px circles).
class QfStepper extends StatelessWidget {
  const QfStepper({super.key, required this.value, required this.onMinus, required this.onPlus});

  final String value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget circle(IconData icon, VoidCallback? onTap, bool filled, String label) => Semantics(
          button: true,
          label: label,
          child: InkResponse(
            onTap: onTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.ink : AppColors.bg,
                border: filled ? null : Border.all(color: AppColors.hairline),
              ),
              child: Icon(icon,
                  size: 20,
                  color: filled ? AppColors.onInk : (onTap == null ? AppColors.hairline : AppColors.ink)),
            ),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      circle(LucideIcons.minus, onMinus, false, 'Decrease'),
      SizedBox(
        width: 64,
        child: Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: AppText.family, fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink)),
      ),
      circle(LucideIcons.plus, onPlus, true, 'Increase'),
    ]);
  }
}

/// Compact inline stepper for list rows: − value +.
class QfMiniStepper extends StatelessWidget {
  const QfMiniStepper({super.key, required this.value, required this.onMinus, required this.onPlus});

  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget circle(IconData icon, VoidCallback onTap, bool filled, String label) => Semantics(
          button: true,
          label: label,
          child: InkResponse(
            onTap: onTap,
            radius: 22,
            child: SizedBox.square(
              dimension: AppSpacing.tap,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.ink : AppColors.bg,
                    border: filled ? null : Border.all(color: AppColors.hairline),
                  ),
                  child: Icon(icon, size: 16, color: filled ? AppColors.onInk : AppColors.ink),
                ),
              ),
            ),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      circle(LucideIcons.minus, onMinus, false, 'Decrease'),
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 28),
        child: Text(value, textAlign: TextAlign.center, style: AppText.bodyStrong),
      ),
      circle(LucideIcons.plus, onPlus, true, 'Increase'),
    ]);
  }
}
