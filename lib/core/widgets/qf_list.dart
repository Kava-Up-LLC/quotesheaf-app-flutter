import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class QfSectionLabel extends StatelessWidget {
  const QfSectionLabel(this.text, {super.key, this.trailing, this.onTrailingTap, this.action});

  final String text;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  /// A widget on the right (e.g. a [QfSmallButton]); replaces [trailing].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, AppSpacing.labelTop, AppSpacing.side, AppSpacing.labelBottom),
      child: Row(children: [
        Expanded(child: Text(text, style: AppText.captionStrong)),
        if (action != null)
          action!
        else if (trailing != null)
          onTrailingTap == null
              ? Text(trailing!, style: AppText.caption)
              : InkWell(
                  onTap: onTrailingTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32),
                    child: Center(
                      child: Text(trailing!, style: AppText.captionStrong.copyWith(color: AppColors.ink, fontSize: 14)),
                    ),
                  ),
                ),
      ]),
    );
  }
}

/// Full-width list row separated by a hairline (DESIGN.md §3).
class QfRow extends StatelessWidget {
  const QfRow({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
    this.subtitleWidget,
    this.meta,
    this.onTap,
    this.chevron = false,
    this.titleStyle,
  });

  final String title;
  final String? trailing;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String? meta;
  final VoidCallback? onTap;
  final bool chevron;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final sub = subtitleWidget ?? (subtitle == null ? null : Text(subtitle!, style: AppText.caption));
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side, vertical: AppSpacing.rowV),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(title, style: titleStyle ?? AppText.body)),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  Text(trailing!, style: AppText.bodyStrong, maxLines: 1, softWrap: false),
                ],
              ]),
              if (sub != null || meta != null) ...[
                const SizedBox(height: AppSpacing.gapTitle),
                Row(children: [
                  Expanded(child: sub ?? const SizedBox()),
                  if (meta != null) ...[
                    const SizedBox(width: 8),
                    Text(meta!, style: AppText.caption, maxLines: 1),
                  ],
                ]),
              ],
            ]),
          ),
          if (chevron) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 22, color: AppColors.muted),
          ],
        ]),
      ),
    );
  }
}

/// Subtotal · tax · Total + tax.
class QfMoneyBlock extends StatelessWidget {
  const QfMoneyBlock({
    super.key,
    required this.subtotal,
    required this.taxLabel,
    required this.tax,
    required this.total,
    this.itemCount,
    this.padding = EdgeInsets.zero,
  });

  /// When set, the first row reads "Subtotal · 3 items".
  final int? itemCount;

  final String subtotal;
  final String taxLabel;
  final String tax;
  final String total;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget row(String l, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(child: Text(l, style: AppText.small, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 12),
            Text(v, style: AppText.small),
          ]),
        );
    return Padding(
      padding: padding,
      child: Column(children: [
        row(itemCount == null ? 'Subtotal' : 'Subtotal · $itemCount item${itemCount == 1 ? '' : 's'}', subtotal),
        row(taxLabel, tax),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('Total + tax', style: AppText.callout.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          // Never truncate totals (DESIGN §7): scale down on narrow screens / large fonts.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(total, style: AppText.amountLg, maxLines: 1),
            ),
          ),
        ]),
      ]),
    );
  }
}
