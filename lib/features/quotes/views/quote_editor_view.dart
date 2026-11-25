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
import '../../../core/widgets/qf_item_sheet.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../../customers/data/models/customer.dart';
import '../../services/data/models/service.dart';
import '../data/models/line_item.dart';
import '../viewmodels/quote_editor_viewmodel.dart';

class QuoteEditorView extends ConsumerWidget {
  const QuoteEditorView({super.key, required this.quoteKey, this.customerId});

  final String quoteKey;
  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quoteEditorViewModelProvider(quoteKey, customerId);
    final async = ref.watch(provider);
    final s = async.value;

    return PopScope(
      canPop: !(s?.dirty ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscard(context);
        if (discard == true && context.mounted) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            QfNavBar(
              backLabel: 'Quotes',
              onBack: () => Navigator.of(context).maybePop(),
              title: s == null ? '' : (s.number ?? 'New Quote'),
              subtitle: s == null ? null : 'valid until ${Fmt.shortDate(s.validUntil)}',
            ),
            Expanded(
              child: async.when(
                loading: () => const QfLoading(),
                error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(provider)),
                data: (s) => _EditorBody(quoteKey: quoteKey, customerId: customerId, state: s),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: s == null ? null : _EditorDock(quoteKey: quoteKey, customerId: customerId, state: s),
      ),
    );
  }

  static Future<bool?> _confirmDiscard(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bg,
          title: const Text('Discard changes?', style: AppText.sheetTitle),
          content: const Text('Your changes to this quote will be lost.', style: AppText.callout),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard', style: TextStyle(color: AppColors.error))),
          ],
        ),
      );
}

class _EditorBody extends ConsumerWidget {
  const _EditorBody({required this.quoteKey, required this.customerId, required this.state});

  final String quoteKey;
  final String? customerId;
  final QuoteEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quoteEditorViewModelProvider(quoteKey, customerId).notifier);
    final c = state.customer;

    final routeId = {'id': state.quoteId ?? AppRoutes.newQuoteKey};

    Future<void> pickCustomer() async {
      final picked = await context.pushNamed<Customer>(AppRoutes.quotePickCustomer, pathParameters: routeId);
      if (picked != null) vm.setCustomer(picked);
    }


    Future<void> addService() async {
      final picked = await context.pushNamed<List<ServiceSelection>>(AppRoutes.quoteAddService, pathParameters: routeId);
      if (picked != null && picked.isNotEmpty) {
        vm.addServices(picked);
        if (context.mounted) {
          showQfToast(context, '${picked.length} service${picked.length == 1 ? '' : 's'} added');
        }
      }
    }

    Future<void> editLine(LineItem l) async {
      final r = await showItemSheet(
        context,
        name: l.name,
        unit: l.unit,
        unitPrice: l.unitPrice,
        quantity: l.quantity,
        step: state.stepFor(l),
        taxable: l.taxable,
        description: l.description ?? '',
        actionLabel: 'Update line',
        source: 'on this quote',
      );
      if (r != null) {
        vm.updateLine(l.id,
            description: r.description, quantity: r.quantity, unitPrice: r.unitPrice, taxable: r.taxable);
      }
    }

    void removeLine(LineItem l) {
      final index = vm.removeLine(l.id);
      showQfToast(context, 'Removed ${l.name}',
          actionLabel: 'Undo', onAction: () => vm.restoreLine(index, l), seconds: 4);
    }

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      const QfSectionLabel('Customer'),
      if (c == null)
        QfRow(
          title: 'Add customer',
          subtitle: 'Choose a saved customer or create a new one',
          chevron: true,
          onTap: pickCustomer,
        )
      else
        QfRow(
          title: c.name,
          subtitle: [if (c.phone != null) Fmt.phone(c.phone!), ?c.email].join(' · ').ifEmpty('No phone or email'),
          chevron: true,
          onTap: pickCustomer,
        ),
      QfSectionLabel(
        'Services',
        action: QfSmallButton(label: 'Add service', icon: LucideIcons.plus, onPressed: addService),
      ),
      if (state.lines.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side, vertical: 8),
          child: Text('No services yet.', style: AppText.callout.copyWith(color: AppColors.muted)),
        ),
      for (final l in state.lines)
        Dismissible(
          key: ValueKey(l.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.side),
            child: Text('Remove', style: AppText.button.copyWith(color: AppColors.onInk)),
          ),
          onDismissed: (_) => removeLine(l),
          child: QfRow(
            title: l.name,
            trailing: Money.format(l.lineTotal),
            subtitle: '${Money.formatQty(l.quantity)} ${l.unit} × ${Money.format(l.unitPrice)}'
                '${l.taxable ? '' : ' · not taxable'}',
            onTap: () => editLine(l),
          ),
        ),
      if (state.error != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 16, AppSpacing.side, 0),
          child: Text('${state.error} Try again.', style: AppText.error.copyWith(fontSize: 14)),
        ),
    ]);
  }
}

class _EditorDock extends ConsumerWidget {
  const _EditorDock({required this.quoteKey, required this.customerId, required this.state});

  final String quoteKey;
  final String? customerId;
  final QuoteEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quoteEditorViewModelProvider(quoteKey, customerId).notifier);
    final t = state.totals;

    Future<void> save() async {
      final wasNew = quoteKey == AppRoutes.newQuoteKey;
      final id = await vm.save();
      if (id == null || !context.mounted) return;
      final number = ref.read(quoteEditorViewModelProvider(quoteKey, customerId)).value?.number;
      showQfToast(context, '${number ?? 'Quote'} saved');
      // New quote → its detail replaces the editor; an edit returns to the detail it came from.
      if (wasNew) {
        context.pushReplacementNamed(AppRoutes.quoteDetail, pathParameters: {'id': id});
      } else {
        context.pop();
      }
    }

    Future<void> preview() async {
      final id = await vm.save(forPreview: true);
      if (id != null && context.mounted) {
        context.pushNamed(AppRoutes.quotePreview, pathParameters: {'id': id});
      }
    }

    return QfDock(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        QfMoneyBlock(
          itemCount: state.lines.length,
          subtotal: Money.format(t.subtotal),
          taxLabel: state.taxDisplay,
          tax: Money.format(t.tax),
          total: Money.format(t.total),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: QfPillButton(
              label: 'Save',
              style: QfButtonStyle.outlined,
              busy: state.saving && !state.savingForPreview,
              onPressed: state.canSave ? save : null,
            ),
          ),
          const SizedBox(width: AppSpacing.gapButtons),
          Expanded(
            child: QfPillButton(
              label: 'Preview',
              busy: state.saving && state.savingForPreview,
              onPressed: state.canPreview ? preview : null,
            ),
          ),
        ]),
      ]),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
