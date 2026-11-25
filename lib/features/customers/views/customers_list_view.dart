import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/qf_buttons.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_inputs.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../data/models/customer.dart';
import '../viewmodels/customers_list_viewmodel.dart';

class CustomersListView extends ConsumerWidget {
  const CustomersListView({super.key});

  static String _count(Customer c) => switch (c.quoteCount) {
        0 => 'no quotes yet',
        1 => '1 quote',
        final n => '$n quotes',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(customersListViewModelProvider);
    final vm = ref.read(customersListViewModelProvider.notifier);
    final s = async.value;

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          QfMainHeader(
            kicker: s?.businessName ?? '',
            title: 'Customers',
            actions: [
              QfIconButton(
                  icon: LucideIcons.fileText300, label: 'Quotes', onTap: () => context.goNamed(AppRoutes.quotes)),
              QfIconButton(
                  icon: LucideIcons.settings300,
                  label: 'Business',
                  onTap: () => context.pushNamed(AppRoutes.business)),
            ],
          ),
          QfSearchField(hint: 'Name, phone or email', onChanged: vm.setQuery),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: vm.refresh),
              data: (s) {
                final visible = s.visible;
                return RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: vm.refresh,
                  child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
                    QfSectionLabel(
                      '${s.customers.length} customer${s.customers.length == 1 ? '' : 's'} · A–Z',
                      action: QfSmallButton(
                        label: 'New customer',
                        icon: LucideIcons.plus,
                        onPressed: () => context.pushNamed(AppRoutes.customerNew),
                      ),
                    ),
                    if (s.customers.isEmpty)
                      const QfEmpty(title: 'No customers yet', message: 'Register a customer to send them quotes.')
                    else if (visible.isEmpty)
                      const QfEmpty(title: 'No matching customers'),
                    for (final c in visible)
                      QfRow(
                        title: c.name,
                        subtitle: c.phone != null ? Fmt.phone(c.phone!) : (c.email ?? 'No phone or email'),
                        meta: _count(c),
                        onTap: () => context.pushNamed(AppRoutes.customerDetail, pathParameters: {'id': c.id}),
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
