import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/data_version.dart';
import '../../business/data/repositories/business_repository.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

part 'customers_list_viewmodel.g.dart';

class CustomersListState {
  const CustomersListState({required this.customers, required this.businessName, this.query = ''});

  final List<Customer> customers;
  final String businessName;
  final String query;

  List<Customer> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;
    final digits = q.replaceAll(RegExp(r'\D'), '');
    return customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q) ||
            (digits.length >= 3 && (c.phone ?? '').contains(digits)))
        .toList();
  }
}

@riverpod
class CustomersListViewModel extends _$CustomersListViewModel {
  @override
  Future<CustomersListState> build() async {
    ref.watch(dataVersionProvider);
    final results = await Future.wait([
      ref.read(customerRepositoryProvider).all(),
      ref.read(businessRepositoryProvider).profile().then((p) => p.shortName).catchError((_) => ''),
    ]);
    return CustomersListState(
      customers: results[0] as List<Customer>,
      businessName: results[1] as String,
      query: state.value?.query ?? '',
    );
  }

  void setQuery(String q) {
    final s = state.value;
    if (s != null) state = AsyncData(CustomersListState(customers: s.customers, businessName: s.businessName, query: q));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
