import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';
import 'qf_buttons.dart';
import 'qf_inputs.dart';
import 'qf_sheet.dart';

/// Result of the item sheet.
class ItemSheetResult {
  const ItemSheetResult({required this.description, required this.quantity, required this.unitPrice, required this.taxable});

  final String description;
  final double quantity;
  final int unitPrice;
  final bool taxable;
}

/// Opens the line-item sheet used by Add service and by the editor (DESIGN.md §4.4).
Future<ItemSheetResult?> showItemSheet(
  BuildContext context, {
  required String name,
  required String unit,
  required int unitPrice,
  required double quantity,
  required double step,
  required bool taxable,
  required String description,
  required String actionLabel,
  String source = 'from your catalog',
}) {
  return showQfSheet<ItemSheetResult>(
    context,
    builder: (_) => _ItemSheet(
      name: name,
      unit: unit,
      unitPrice: unitPrice,
      quantity: quantity,
      step: step,
      taxable: taxable,
      description: description,
      actionLabel: actionLabel,
      source: source,
    ),
  );
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.step,
    required this.taxable,
    required this.description,
    required this.actionLabel,
    required this.source,
  });

  final String name;
  final String unit;
  final int unitPrice;
  final double quantity;
  final double step;
  final bool taxable;
  final String description;
  final String actionLabel;
  final String source;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  late final _description = TextEditingController(text: widget.description);
  late final _price = TextEditingController(text: (widget.unitPrice / 100).toStringAsFixed(2));
  late double _qty = widget.quantity;
  late int _unitPrice = widget.unitPrice;
  late bool _taxable = widget.taxable;
  bool _editPrice = false;

  @override
  void dispose() {
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  void _onPrice(String v) {
    final d = double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (d != null) setState(() => _unitPrice = Money.fromDollars(d));
  }

  @override
  Widget build(BuildContext context) {
    final tax = _taxable ? 'taxable' : 'not taxable';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text(widget.name, style: AppText.sheetTitle),
      const SizedBox(height: 4),
      Semantics(
        button: true,
        label: 'Edit price',
        child: InkWell(
          onTap: () => setState(() => _editPrice = !_editPrice),
          child: Text('${Money.format(_unitPrice)} per ${widget.unit} · $tax · ${widget.source}', style: AppText.small),
        ),
      ),
      if (_editPrice) ...[
        const SizedBox(height: AppSpacing.gapSheet),
        QfTextField(
          label: 'Price per ${widget.unit}',
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _onPrice,
        ),
      ],
      const SizedBox(height: AppSpacing.gapSheet),
      QfTextField(label: 'Description', controller: _description, maxLines: 3,
          textCapitalization: TextCapitalization.sentences),
      const SizedBox(height: AppSpacing.gapSheet),
      Row(children: [
        Expanded(child: Text('Quantity (${widget.unit})', style: AppText.callout.copyWith(color: AppColors.muted))),
        QfStepper(
          value: Money.formatQty(_qty),
          onMinus: _qty - widget.step <= 0 ? null : () => setState(() => _qty -= widget.step),
          onPlus: () => setState(() => _qty += widget.step),
        ),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Text('Taxable', style: AppText.callout.copyWith(color: AppColors.muted))),
        CupertinoSwitch(
          value: _taxable,
          activeTrackColor: AppColors.ink,
          onChanged: (v) => setState(() => _taxable = v),
        ),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Text('Line total', style: AppText.callout.copyWith(color: AppColors.muted))),
        Text(Money.format(Money.lineTotal(_unitPrice, _qty)), style: AppText.amountLg.copyWith(fontSize: 26)),
      ]),
      const SizedBox(height: 20),
      QfPillButton(
        label: widget.actionLabel,
        onPressed: () => Navigator.of(context).pop(ItemSheetResult(
          description: _description.text.trim(),
          quantity: _qty,
          unitPrice: _unitPrice,
          taxable: _taxable,
        )),
      ),
    ]);
  }
}
