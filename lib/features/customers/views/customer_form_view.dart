import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_states.dart';
import '../viewmodels/customer_form_viewmodel.dart';
import '../widgets/customer_fields.dart';

/// Register a new customer or edit an existing one.
class CustomerFormView extends ConsumerStatefulWidget {
  const CustomerFormView({super.key, this.customerId, this.returnToQuote = false});

  final String? customerId;

  /// Opened from a quote: pops the saved (or existing duplicate) customer back to the editor.
  final bool returnToQuote;

  @override
  ConsumerState<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends ConsumerState<CustomerFormView> {
  CustomerControllers? _c;

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = ref.read(customerFormViewModelProvider(widget.customerId).notifier);
    final saved = await vm.save(_c!.input);
    if (saved == null || !mounted) return;
    showQfToast(context, widget.customerId == null ? '${saved.name} added' : '${saved.name} saved');
    if (widget.returnToQuote) {
      context.pop(saved);
      return;
    }
    if (widget.customerId == null) {
      context.pushReplacementNamed(AppRoutes.customerDetail, pathParameters: {'id': saved.id});
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = customerFormViewModelProvider(widget.customerId);
    final async = ref.watch(provider);
    final s = async.value;
    if (s != null) _c ??= CustomerControllers(s.initial);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          QfNavBar(
            backLabel: 'Cancel',
            title: s?.isEdit == true ? 'Edit customer' : 'New customer',
            action: s == null ? null : QfNavAction(label: 'Save', busy: s.saving, onTap: _save),
          ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(provider)),
              data: (s) => ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 12, AppSpacing.side, 32),
                children: [
                  CustomerFields(
                    controllers: _c!,
                    errors: s.errors,
                    duplicate: s.duplicate,
                    onUseDuplicate: s.duplicate == null
                        ? null
                        : () => widget.returnToQuote
                            ? context.pop(s.duplicate)
                            : context.pushReplacementNamed(AppRoutes.customerDetail,
                                pathParameters: {'id': s.duplicate!.id}),
                  ),
                  if (s.saveError != null) ...[
                    const SizedBox(height: 12),
                    Text('${s.saveError} Retry.', style: AppText.error.copyWith(fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
