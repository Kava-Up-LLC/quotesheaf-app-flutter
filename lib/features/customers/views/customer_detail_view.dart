import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/qf_buttons.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../viewmodels/customer_detail_viewmodel.dart';

class CustomerDetailView extends ConsumerWidget {
  const CustomerDetailView({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customerDetailViewModelProvider(customerId);
    final async = ref.watch(provider);
    final s = async.value;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          QfNavBar(
            backLabel: 'Customers',
            action: s == null
                ? null
                : QfNavAction(
                    label: 'Edit',
                    onTap: () => context.pushNamed(AppRoutes.customerEdit, pathParameters: {'id': customerId}),
                  ),
          ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(provider)),
              data: (s) {
                final c = s.customer;
                const pad = EdgeInsets.symmetric(horizontal: AppSpacing.side);
                return RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: () async => ref.invalidate(provider),
                  child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
                  Padding(
                    padding: pad.copyWith(top: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: AppText.titleDetail),
                      if (c.notes != null) ...[
                        const SizedBox(height: 6),
                        Text('Private note: ${c.notes}', style: AppText.callout.copyWith(color: AppColors.muted)),
                      ],
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideDock, 18, AppSpacing.sideDock, 0),
                    child: QfPillButton(
                      label: 'New quote for ${c.firstName}',
                      icon: LucideIcons.plus,
                      style: QfButtonStyle.soft,
                      onPressed: () => context.pushNamed(AppRoutes.quoteNew, queryParameters: {'customerId': c.id}),
                    ),
                  ),
                  const QfSectionLabel('Contact'),
                  if (c.phone != null) QfRow(title: Fmt.phone(c.phone!), subtitle: 'Mobile · used for Text'),
                  if (c.email != null) QfRow(title: c.email!, subtitle: 'Email'),
                  if (c.address != null) QfRow(title: c.address!, subtitle: 'Address'),
                  if (c.phone == null && c.email == null)
                    Padding(
                      padding: pad,
                      child: Text('No phone or email — add one to send quotes by Text or Email.',
                          style: AppText.small),
                    ),
                  const QfSectionLabel('Quotes'),
                  if (s.quotes.isEmpty)
                    Padding(padding: pad, child: Text('No quotes yet.', style: AppText.small)),
                  for (final q in s.quotes)
                    QfRow(
                      title: 'Quote ${q.number}',
                      trailing: Money.format(q.total),
                      subtitle: 'valid until ${Fmt.shortDate(q.validUntil)}',
                      meta: Fmt.shortDate(q.issueDate),
                      onTap: () => context.pushNamed(AppRoutes.quoteDetail, pathParameters: {'id': q.id}),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
