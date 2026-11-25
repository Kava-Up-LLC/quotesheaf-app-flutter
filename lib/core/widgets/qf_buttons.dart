import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum QfButtonStyle { primary, outlined, soft }

class QfPillButton extends StatelessWidget {
  const QfPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = QfButtonStyle.primary,
    this.icon,
    this.height = 52,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final QfButtonStyle style;
  final IconData? icon;
  final double height;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      QfButtonStyle.primary => (AppColors.ink, AppColors.onInk, null),
      QfButtonStyle.outlined => (AppColors.bg, AppColors.ink, Border.all(color: AppColors.hairline)),
      QfButtonStyle.soft => (AppColors.tint, AppColors.ink, null),
    };
    final enabled = onPressed != null && !busy;
    return Opacity(
      opacity: onPressed == null && !busy ? 0.4 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          customBorder: const StadiumBorder(),
          child: Ink(
            height: height,
            decoration: BoxDecoration(color: bg, border: border, borderRadius: BorderRadius.circular(height / 2)),
            child: Center(
              child: busy
                  ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 10)],
                      Flexible(
                        child: Text(label,
                            style: AppText.button.copyWith(color: fg, fontSize: height >= 54 ? 17 : 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact outlined pill for secondary actions inside a section ("+ Add service").
class QfSmallButton extends StatelessWidget {
  const QfSmallButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: AppColors.ink), const SizedBox(width: 6)],
            Text(label, style: AppText.button.copyWith(fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}

/// Plain ink text link ("Resend", "Undo — mark as Sent again").
class QfTextLink extends StatelessWidget {
  const QfTextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.tap),
        child: Align(alignment: Alignment.centerLeft, child: Text(label, style: AppText.button)),
      ),
    );
  }
}

/// Bottom dock with a top hairline (editor / preview).
class QfDock extends StatelessWidget {
  const QfDock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.sideDock, 14, AppSpacing.sideDock, AppSpacing.dockBottomFor(bottom)),
      child: child,
    );
  }
}

/// Fixed full-width CTA at the bottom of Home ("New Quote").
class QfFixedCta extends StatelessWidget {
  const QfFixedCta({super.key, required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.sideDock, 8, AppSpacing.sideDock, AppSpacing.dockBottomFor(bottom)),
      child: QfPillButton(label: label, icon: icon, height: 56, onPressed: onPressed),
    );
  }
}
