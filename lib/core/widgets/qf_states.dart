import 'package:flutter/material.dart';

import '../errors/failure.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'qf_buttons.dart';

class QfLoading extends StatelessWidget {
  const QfLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox.square(
              dimension: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink)),
        ),
      );
}

class QfError extends StatelessWidget {
  const QfError({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final msg = error is Failure ? (error as Failure).message : Failure.loadFailed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.side),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg, style: AppText.callout.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            child: QfPillButton(label: 'Retry', style: QfButtonStyle.outlined, height: 44, onPressed: onRetry),
          ),
        ]),
      ),
    );
  }
}

class QfEmpty extends StatelessWidget {
  const QfEmpty({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 48, AppSpacing.side, 24),
      child: Column(children: [
        Text(title, style: AppText.sheetTitle, textAlign: TextAlign.center),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(message!, style: AppText.callout.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
        ],
      ]),
    );
  }
}

/// Short toast anchored to the bottom of the screen (above the home indicator),
/// drawn on the root overlay so it sits over docks and survives navigation.
void showQfToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  int seconds = 3,
}) {
  _QfToast.show(
    Overlay.of(context, rootOverlay: true),
    message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: Duration(seconds: seconds),
  );
}

abstract final class _QfToast {
  static OverlayEntry? _current;

  static void show(OverlayState overlay, String message,
      {String? actionLabel, VoidCallback? onAction, required Duration duration}) {
    _current?.remove();
    late final OverlayEntry entry;
    void dismiss() {
      if (_current == entry) _current = null;
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(
      builder: (ctx) => _ToastView(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                onAction();
                dismiss();
              },
        duration: duration,
        onDone: dismiss,
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.onDone,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 180))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _anim.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: AppSpacing.sideDock,
      right: AppSpacing.sideDock,
      bottom: AppSpacing.dockBottomFor(bottom),
      child: FadeTransition(
        opacity: _anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(_anim),
          child: Material(
            color: AppColors.ink,
            elevation: 6,
            borderRadius: BorderRadius.circular(AppSpacing.radiusField),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
              child: Row(children: [
                Expanded(
                  child: Text(widget.message, style: AppText.callout.copyWith(color: AppColors.onInk)),
                ),
                if (widget.actionLabel != null)
                  TextButton(
                    onPressed: widget.onAction,
                    child: Text(widget.actionLabel!, style: AppText.button.copyWith(color: AppColors.onInk)),
                  )
                else
                  const SizedBox(width: 10),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error text for a failed save/load.
String failureMessage(Object error) => error is Failure ? error.message : Failure.saveFailed;
