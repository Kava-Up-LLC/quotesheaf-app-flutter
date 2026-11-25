import 'package:appambit_sdk_flutter/appambit_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/qf_buttons.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_inputs.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../data/models/quote.dart';
import '../viewmodels/quotes_list_viewmodel.dart';

class QuotesListView extends ConsumerWidget {
  const QuotesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(quotesListViewModelProvider);
    final vm = ref.read(quotesListViewModelProvider.notifier);
    final s = async.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Long-press the title to throw a test crash (shows up in AppAmbit → Crashes).
          GestureDetector(
            onLongPress: AppAmbitSdk.generateTestCrash,
            child: QfMainHeader(
            kicker: s?.businessName ?? '',
            title: 'Quotes',
            actions: [
              QfIconButton(
                  icon: LucideIcons.users300,
                  label: 'Customers',
                  onTap: () => context.goNamed(AppRoutes.customers)),
              QfIconButton(
                  icon: LucideIcons.settings300,
                  label: 'Business',
                  onTap: () => context.pushNamed(AppRoutes.business)),
            ],
          )),
          QfSearchField(hint: 'Customer, phone or Q-number', onChanged: vm.setQuery),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: vm.refresh),
              data: (s) => RefreshIndicator(
                color: AppColors.ink,
                onRefresh: vm.refresh,
                child: _QuotesList(state: s),
              ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: QfFixedCta(
        label: 'New Quote',
        icon: LucideIcons.plus,
        onPressed: () => context.pushNamed(AppRoutes.quoteNew),
      ),
    );
  }
}

class _QuotesList extends StatelessWidget {
  const _QuotesList({required this.state});

  final QuotesListState state;

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) {
      return ListView(children: const [
        QfEmpty(title: 'No quotes yet', message: 'Create your first quote in under 2 minutes.'),
      ]);
    }
    final visible = state.visible;
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      const QfSectionLabel('All quotes · by customer', trailing: 'incl. tax'),
      for (final q in visible) _QuoteRow(quote: q),
      if (visible.isEmpty) const QfEmpty(title: 'No matching quotes'),
    ]);
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return QfRow(
      title: quote.customerName,
      trailing: Money.format(quote.total),
      subtitle: quote.number,
      meta: Fmt.shortDate(quote.issueDate),
      onTap: () => context.pushNamed(AppRoutes.quoteDetail, pathParameters: {'id': quote.id}),
    );
  }
}
