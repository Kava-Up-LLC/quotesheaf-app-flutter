import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_inputs.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../data/models/customer.dart';
import '../viewmodels/customer_picker_viewmodel.dart';

/// Customer for a quote: create a new one or choose a saved one. Pops the [Customer].
class CustomerPickerView extends ConsumerWidget {
  const CustomerPickerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(customerPickerViewModelProvider);
    final vm = ref.read(customerPickerViewModelProvider.notifier);

    Future<void> createNew() async {
      final id = GoRouterState.of(context).pathParameters['id']!;
      final created = await context.pushNamed<Customer>(AppRoutes.quoteNewCustomer, pathParameters: {'id': id});
      if (created != null && context.mounted) context.pop(created);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const QfNavBar(backLabel: 'Cancel', title: 'Customer'),
          QfSearchField(hint: 'Name, phone or email', onChanged: vm.setQuery),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(customerPickerViewModelProvider)),
              data: (s) {
                final visible = s.visible;
                return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
                  _NewCustomerRow(onTap: createNew),
                  QfSectionLabel(s.query.trim().isEmpty ? 'Your customers · A–Z' : 'Results'),
                  if (s.all.isEmpty)
                    const QfEmpty(title: 'No customers yet', message: 'Create your first one above.')
                  else if (visible.isEmpty)
                    const QfEmpty(title: 'No matching customers'),
                  for (final c in visible)
                    QfRow(
                      title: c.name,
                      subtitle: c.phone != null ? Fmt.phone(c.phone!) : (c.email ?? 'No phone or email'),
                      onTap: () => context.pop(c),
                    ),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _NewCustomerRow extends StatelessWidget {
  const _NewCustomerRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side, vertical: AppSpacing.rowV),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
            child: const Icon(LucideIcons.userPlus, size: 18, color: AppColors.onInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('New customer', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
              Text('Only the name is required', style: AppText.caption),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 22, color: AppColors.muted),
        ]),
      ),
    );
  }
}
