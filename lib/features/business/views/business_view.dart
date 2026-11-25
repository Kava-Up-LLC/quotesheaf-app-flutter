import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../viewmodels/business_viewmodel.dart';

/// Business profile from the CMS — read-only (PRD §5.9).
class BusinessView extends ConsumerWidget {
  const BusinessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(businessViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const QfNavBar(backLabel: 'Back', title: 'Business'),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(businessViewModelProvider)),
              data: (s) {
                final p = s.profile;
                return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 0),
                    child: Text('Read-only here · change it in your AppAmbit dashboard', style: AppText.small),
                  ),
                  const QfSectionLabel('Profile'),
                  QfRow(
                    title: p.name,
                    subtitle: [?p.tradeLabel, ?p.licenseNo].join(' · '),
                  ),
                  if (p.address != null || p.phone != null)
                    QfRow(
                      title: p.address ?? p.phone!,
                      subtitle: [if (p.address != null) ?p.phone, ?p.email].join(' · '),
                    ),
                  const QfSectionLabel('Quotes'),
                  QfRow(title: 'Tax', trailing: s.taxDisplay, subtitle: p.taxName),
                  QfRow(title: 'Quotes valid for', trailing: '${p.validDays} days'),
                  if (s.nextNumber != null) QfRow(title: 'Next quote', trailing: s.nextNumber),
                  if (!s.footer.isEmpty) ...[
                    QfSectionLabel(s.footer.title ?? 'Quote footer'),
                    for (final m in s.footer.methods) QfRow(title: m.label, subtitle: m.value),
                  ],
                  const QfSectionLabel('Catalog'),
                  QfRow(title: 'Services & prices', trailing: '${s.serviceCount}', subtitle: 'Used in Add service'),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
