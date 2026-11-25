import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/failure.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';
import 'customer_save_flow.dart';

part 'customer_form_viewmodel.g.dart';

class CustomerFormState {
  const CustomerFormState({this.initial, this.errors = const {}, this.duplicate, this.saving = false, this.saveError});

  /// The customer being edited (null when registering).
  final Customer? initial;
  final Map<String, String> errors;
  final Customer? duplicate;
  final bool saving;
  final String? saveError;

  bool get isEdit => initial != null;
}

/// Register (customerId == null) or edit a customer.
@riverpod
class CustomerFormViewModel extends _$CustomerFormViewModel {
  @override
  Future<CustomerFormState> build(String? customerId) async {
    if (customerId == null) return const CustomerFormState();
    final c = await ref.read(customerRepositoryProvider).byId(customerId);
    if (c == null) throw const Failure('This customer no longer exists.');
    return CustomerFormState(initial: c);
  }

  /// Returns the saved customer, or null when there are errors / a duplicate warning.
  Future<Customer?> save(CustomerInput input) async {
    final s = state.value;
    if (s == null || s.saving) return null;
    state = AsyncData(CustomerFormState(initial: s.initial, duplicate: s.duplicate, saving: true));
    final outcome = await saveCustomer(ref.read(customerRepositoryProvider), input,
        id: customerId, acknowledgedDuplicateId: s.duplicate?.id);
    if (!ref.mounted) return null;
    switch (outcome) {
      case CustomerSaved(:final customer):
        state = AsyncData(CustomerFormState(initial: s.initial));
        return customer;
      case CustomerInvalid(:final errors):
        state = AsyncData(CustomerFormState(initial: s.initial, errors: errors));
      case CustomerDuplicate(:final existing):
        state = AsyncData(CustomerFormState(initial: s.initial, duplicate: existing));
      case CustomerSaveFailed(:final message):
        state = AsyncData(CustomerFormState(initial: s.initial, saveError: message));
    }
    return null;
  }
}
