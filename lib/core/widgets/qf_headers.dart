import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Main header (Quotes / Customers): kicker + big title + icon actions.
class QfMainHeader extends StatelessWidget {
  const QfMainHeader({super.key, required this.kicker, required this.title, required this.actions});

  final String kicker;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 16, 12, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(kicker, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppText.title, maxLines: 1),
            ),
          ]),
        ),
        ...actions,
      ]),
    );
  }
}

class QfIconButton extends StatelessWidget {
  const QfIconButton({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox.square(dimension: AppSpacing.tap, child: Icon(icon, size: 21, color: AppColors.ink)),
      ),
    );
  }
}

/// Inner-screen nav bar: back link · title/subtitle · optional action.
class QfNavBar extends StatelessWidget {
  const QfNavBar({
    super.key,
    this.backLabel,
    this.onBack,
    this.title,
    this.subtitle,
    this.action,
  });

  final String? backLabel;
  final VoidCallback? onBack;
  final String? title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final side = (MediaQuery.sizeOf(context).width * 0.3).clamp(88.0, 124.0);
    return SizedBox(
      height: 56,
      child: Row(children: [
        SizedBox(
          width: side,
          child: backLabel == null
              ? null
              : Semantics(
                  button: true,
                  label: backLabel,
                  child: InkWell(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(children: [
                        const Icon(LucideIcons.chevronLeft, size: 22, color: AppColors.ink),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(backLabel!,
                              style: AppText.body.copyWith(fontWeight: FontWeight.w400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ),
                  ),
                ),
        ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (title != null)
              Text(title!, style: AppText.button, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (subtitle != null)
              Text(subtitle!,
                  style: AppText.micro.copyWith(fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        SizedBox(
          width: side,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(padding: const EdgeInsets.only(right: 12), child: action),
          ),
        ),
      ]),
    );
  }
}

/// Text action for the nav bar ("Save", "Edit").
class QfNavAction extends StatelessWidget {
  const QfNavAction({super.key, required this.label, required this.onTap, this.busy = false});

  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox.square(
          dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink));
    }
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: AppSpacing.tap,
        child: Center(
          child: Text(label,
              style: AppText.button.copyWith(color: onTap == null ? AppColors.muted : AppColors.ink)),
        ),
      ),
    );
  }
}
