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
import '../data/models/quote.dart';
import '../viewmodels/quote_detail_viewmodel.dart';

class QuoteDetailView extends ConsumerWidget {
  const QuoteDetailView({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quoteDetailViewModelProvider(quoteId);
    final async = ref.watch(provider);
    final s = async.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          QfNavBar(
            backLabel: 'Quotes',
            title: s?.quote.number,
            action: s == null
                ? null
                : QfIconButton(
                    icon: LucideIcons.pencil300,
                    label: 'Edit quote',
                    onTap: () => context.pushNamed(AppRoutes.quoteEdit, pathParameters: {'id': quoteId}),
                  ),
          ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(provider)),
              data: (s) => RefreshIndicator(
                color: AppColors.ink,
                onRefresh: ref.read(provider.notifier).refresh,
                child: _DetailBody(state: s),
              ),
            ),
          ),
        ]),
      ),
      // Checkout-style summary, always visible.
      bottomNavigationBar: s == null
          ? null
          : QfDock(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                QfMoneyBlock(
                  itemCount: s.quote.lines.length,
                  subtotal: Money.format(s.quote.subtotal),
                  taxLabel: s.taxDisplay,
                  tax: Money.format(s.quote.taxAmount),
                  total: Money.format(s.quote.total),
                ),
                const SizedBox(height: 12),
                QfPillButton(
                  label: 'Preview & send',
                  icon: LucideIcons.fileText,
                  onPressed: () => context.pushNamed(AppRoutes.quotePreview, pathParameters: {'id': quoteId}),
                ),
              ]),
            ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state});

  final QuoteDetailState state;

  @override
  Widget build(BuildContext context) {
    final q = state.quote;
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.side);

    return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
      Padding(
        padding: pad.copyWith(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quote for', style: AppText.callout.copyWith(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(q.customerName, style: AppText.titleDetail),
          const SizedBox(height: 6),
          Text(_infoLine(q), style: AppText.callout.copyWith(color: AppColors.muted)),
        ]),
      ),
      QfSectionLabel('Services · ${q.lines.length}'),
      for (final l in q.lines)
        QfRow(
          title: l.name,
          trailing: Money.format(l.lineTotal),
          subtitle: '${Money.formatQty(l.quantity)} ${l.unit} × ${Money.format(l.unitPrice)}',
        ),
    ]);
  }

  /// "Issued Sep 23 · valid 14 days, until Oct 7 · last sent by Text Sep 23"
  static String _infoLine(Quote q) => [
        'Issued ${Fmt.shortDate(q.issueDate)}',
        'valid ${q.validDays} days, until ${Fmt.shortDate(q.validUntil)}',
        if (q.sentAt != null) 'last sent${q.sentVia == null ? '' : ' by ${q.sentVia!.label}'} ${Fmt.shortDate(q.sentAt!)}',
      ].join(' · ');
}
