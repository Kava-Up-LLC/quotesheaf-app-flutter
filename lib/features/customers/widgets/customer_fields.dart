import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/qf_inputs.dart';
import '../data/models/customer.dart';

/// Controllers for the customer form.
class CustomerControllers {
  CustomerControllers([Customer? c])
      : name = TextEditingController(text: c?.name),
        phone = TextEditingController(text: c?.phone == null ? '' : Fmt.phone(c!.phone!)),
        email = TextEditingController(text: c?.email),
        address = TextEditingController(text: c?.address),
        notes = TextEditingController(text: c?.notes);

  final TextEditingController name, phone, email, address, notes;

  CustomerInput get input => CustomerInput(
        name: name.text,
        phone: phone.text,
        email: email.text,
        address: address.text,
        notes: notes.text,
      );

  void dispose() {
    for (final c in [name, phone, email, address, notes]) {
      c.dispose();
    }
  }
}

/// Name · Mobile · Email (+ Address · Notes) with inline validation.
class CustomerFields extends StatelessWidget {
  const CustomerFields({
    super.key,
    required this.controllers,
    required this.errors,
    this.duplicate,
    this.onUseDuplicate,
    this.full = true,
  });

  final CustomerControllers controllers;
  final Map<String, String> errors;
  final Customer? duplicate;
  final VoidCallback? onUseDuplicate;

  /// Shows address and notes too (Customers screen); the quote picker only needs contact.
  final bool full;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.gapFields);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      QfTextField(
        label: 'Name',
        controller: controllers.name,
        placeholder: 'Full name or business',
        error: errors['name'],
        textCapitalization: TextCapitalization.words,
      ),
      gap,
      QfTextField(
        label: 'Mobile',
        controller: controllers.phone,
        placeholder: '+1 808 555 0100',
        hint: 'Optional · needed to send by Text',
        error: errors['phone'],
        keyboardType: TextInputType.phone,
      ),
      gap,
      QfTextField(
        label: 'Email',
        controller: controllers.email,
        placeholder: 'name@email.com',
        hint: 'Optional · needed to send by Email',
        error: errors['email'],
        keyboardType: TextInputType.emailAddress,
      ),
      if (full) ...[
        gap,
        QfTextField(
          label: 'Address',
          controller: controllers.address,
          placeholder: 'Street, city, state ZIP',
          hint: 'Printed on the quote',
          textCapitalization: TextCapitalization.words,
        ),
        gap,
        QfTextField(
          label: 'Private note',
          controller: controllers.notes,
          placeholder: 'Gate code, pets…',
          hint: 'Internal · never printed',
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
      if (duplicate != null) ...[
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(style: AppText.error.copyWith(fontSize: 14), children: [
            TextSpan(text: 'Already saved as ${duplicate!.name}'),
            if (onUseDuplicate != null) ...[
              const TextSpan(text: ' — '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: onUseDuplicate,
                  child: Text('use it?',
                      style: AppText.error.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 4),
        Text('Tap Save again to keep both.', style: AppText.micro.copyWith(color: AppColors.muted)),
      ],
    ]);
  }
}
