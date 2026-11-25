import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/qf_buttons.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_inputs.dart';
import '../../../core/widgets/qf_item_sheet.dart';
import '../../../core/widgets/qf_list.dart';
import '../../../core/widgets/qf_states.dart';
import '../data/models/service.dart';
import '../viewmodels/service_picker_viewmodel.dart';

/// Add services — the only place the CMS catalog appears (PRD §5.6).
/// Several services can be picked at once; pops `List<ServiceSelection>`.
class ServicePickerView extends ConsumerWidget {
  const ServicePickerView({super.key});

  /// Filter chip value for "Selected".
  static const _selectedChip = '\u0000selected';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(servicePickerViewModelProvider);
    final vm = ref.read(servicePickerViewModelProvider.notifier);
    final s = async.value;

    Future<void> editItem(Service svc) async {
      final st = ref.read(servicePickerViewModelProvider).value!;
      final cur = st.picked[svc.id];
      final r = await showItemSheet(
        context,
        name: svc.name,
        unit: svc.unit,
        unitPrice: cur?.unitPrice ?? svc.unitPrice,
        quantity: cur?.quantity ?? st.stepFor(svc),
        step: st.stepFor(svc),
        taxable: cur?.taxable ?? svc.taxable,
        description: cur?.description ?? svc.description ?? '',
        actionLabel: cur == null ? 'Select' : 'Done',
      );
      if (r != null) {
        vm.setItem(
            svc, PickedItem(quantity: r.quantity, description: r.description, unitPrice: r.unitPrice, taxable: r.taxable));
      }
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          QfNavBar(
            backLabel: 'Quote',
            title: 'Add services',
            subtitle: s == null ? null : '${s.services.length} services',
          ),
          Expanded(
            child: async.when(
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(servicePickerViewModelProvider)),
              data: (s) {
                final visible = s.visible;
                final chips = <String?>[
                  null,
                  if (s.pickedCount > 0) _selectedChip,
                  ...s.categories,
                ];
                return ListView(
                    // Clear the (transparent) system navigation bar when no dock is shown.
                    padding: EdgeInsets.only(
                        bottom: 24 + (s.pickedCount == 0 ? MediaQuery.paddingOf(context).bottom : 0)),
                    children: [
                  QfSearchField(hint: 'Search services', onChanged: vm.setQuery),
                  if (s.recent.isNotEmpty && s.query.isEmpty && !s.selectedOnly)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(children: [
                        for (final r in s.recent) _RecentChip(service: r, onTap: () => vm.increment(r)),
                      ]),
                    ),
                  QfFilterChips<String?>(
                    options: chips,
                    selected: s.selectedOnly ? _selectedChip : s.category,
                    labelOf: (c) => switch (c) {
                      null => 'All',
                      _selectedChip => 'Selected · ${s.pickedCount}',
                      final name => name,
                    },
                    onSelected: (c) => c == _selectedChip ? vm.showSelected() : vm.setCategory(c),
                  ),
                  QfSectionLabel(s.selectedOnly
                      ? 'Selected'
                      : s.category ?? (s.query.isEmpty ? 'All services' : 'Results')),
                  if (visible.isEmpty) const QfEmpty(title: 'No services found'),
                  for (final svc in visible)
                    _ServiceRow(
                      service: svc,
                      picked: s.picked[svc.id],
                      onTap: () => editItem(svc),
                      onAdd: () => vm.increment(svc),
                      onRemove: () => vm.decrement(svc),
                    ),
                ]);
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: s == null || s.pickedCount == 0
          ? null
          : QfDock(
              child: Row(children: [
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${s.pickedCount} service${s.pickedCount == 1 ? '' : 's'} selected', style: AppText.small),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(Money.format(s.pickedTotal), style: AppText.amountLg, maxLines: 1),
                    ),
                  ]),
                ),
                const SizedBox(width: AppSpacing.gapButtons),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150, maxWidth: 190),
                  child: QfPillButton(label: 'Add to quote', onPressed: () => context.pop(s.selections)),
                ),
              ]),
            ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.picked,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  final Service service;
  final PickedItem? picked;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = picked;
    final subtitle = p == null
        ? '${Money.format(service.unitPrice)} / ${service.unit} · ${service.taxable ? 'taxable' : 'not taxable'}'
        : '${Money.formatQty(p.quantity)} ${service.unit} × ${Money.format(p.unitPrice)} = ${Money.format(p.lineTotal)}';
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: p == null ? null : AppColors.soft,
          border: const Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 10, 12, 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.name, style: AppText.body),
              const SizedBox(height: AppSpacing.gapTitle),
              Text(subtitle, style: AppText.caption.copyWith(color: p == null ? AppColors.muted : AppColors.ink)),
            ]),
          ),
          const SizedBox(width: 8),
          if (p == null)
            Semantics(
              button: true,
              label: 'Add ${service.name}',
              child: InkResponse(
                onTap: onAdd,
                radius: 22,
                child: SizedBox.square(
                  dimension: AppSpacing.tap,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.hairline)),
                      child: const Icon(LucideIcons.plus, size: 16, color: AppColors.ink),
                    ),
                  ),
                ),
              ),
            )
          else
            QfMiniStepper(value: Money.formatQty(p.quantity), onMinus: onRemove, onPlus: onAdd),
        ]),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.service, required this.onTap});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.hairline),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: service.name),
                TextSpan(
                    text: '  ${Money.formatShort(service.unitPrice)}/${service.unit}',
                    style: const TextStyle(color: AppColors.muted)),
              ]),
              style: AppText.caption.copyWith(color: AppColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
