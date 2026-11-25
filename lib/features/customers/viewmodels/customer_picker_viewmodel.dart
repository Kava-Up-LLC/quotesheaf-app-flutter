import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/data_version.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

part 'customer_picker_viewmodel.g.dart';

class CustomerPickerState {
  const CustomerPickerState({required this.all, this.query = ''});

  final List<Customer> all;
  final String query;

  /// All customers A–Z, or the ones matching name / phone / email.
  List<Customer> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    final digits = q.replaceAll(RegExp(r'\D'), '');
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q) ||
            (digits.length >= 3 && (c.phone ?? '').contains(digits)))
        .toList();
  }
}

/// Choose an existing customer for a quote (registering is a separate screen).
@riverpod
class CustomerPickerViewModel extends _$CustomerPickerViewModel {
  @override
  Future<CustomerPickerState> build() async {
    ref.watch(dataVersionProvider);
    final all = await ref.read(customerRepositoryProvider).all();
    return CustomerPickerState(all: all, query: state.value?.query ?? '');
  }

  void setQuery(String q) {
    final s = state.value;
    if (s != null) state = AsyncData(CustomerPickerState(all: s.all, query: q));
  }
}
