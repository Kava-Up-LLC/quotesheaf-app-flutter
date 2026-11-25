import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Opens a Mono bottom sheet (radius 24, grabber, scrim).
Future<T?> showQfSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.dockBottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 10, AppSpacing.side, 0),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration:
                    BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: AppSpacing.gapSheet),
            builder(ctx),
          ]),
        ),
      ),
    ),
  );
}
