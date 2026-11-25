import '../../../core/errors/failure.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

/// Result of trying to register / update a customer.
sealed class CustomerSaveOutcome {
  const CustomerSaveOutcome();
}

class CustomerSaved extends CustomerSaveOutcome {
  const CustomerSaved(this.customer);
  final Customer customer;
}

class CustomerInvalid extends CustomerSaveOutcome {
  const CustomerInvalid(this.errors);
  final Map<String, String> errors;
}

/// Same phone or email already registered — warn once (PRD §5.8).
class CustomerDuplicate extends CustomerSaveOutcome {
  const CustomerDuplicate(this.existing);
  final Customer existing;
}

class CustomerSaveFailed extends CustomerSaveOutcome {
  const CustomerSaveFailed(this.message);
  final String message;
}

/// Validate → duplicate warning (skipped when [acknowledgedDuplicateId] matches) → save.
Future<CustomerSaveOutcome> saveCustomer(
  CustomerRepository repo,
  CustomerInput input, {
  String? id,
  String? acknowledgedDuplicateId,
}) async {
  final errors = input.validate();
  if (errors.isNotEmpty) return CustomerInvalid(errors);
  try {
    final dup = await repo.findDuplicate(input, excludeId: id);
    if (dup != null && dup.id != acknowledgedDuplicateId) return CustomerDuplicate(dup);
    final saved = id == null ? await repo.create(input) : await repo.update(id, input);
    return CustomerSaved(saved);
  } catch (e) {
    return CustomerSaveFailed(e is Failure ? e.message : Failure.saveFailed);
  }
}
