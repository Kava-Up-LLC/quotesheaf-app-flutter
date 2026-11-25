import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/data_version.dart';
import '../../quotes/data/models/quote.dart';
import '../../quotes/data/repositories/quote_repository.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

part 'customer_detail_viewmodel.g.dart';

class CustomerDetailState {
  const CustomerDetailState({required this.customer, required this.quotes});

  final Customer customer;
  final List<Quote> quotes;
}

@riverpod
class CustomerDetailViewModel extends _$CustomerDetailViewModel {
  @override
  Future<CustomerDetailState> build(String customerId) async {
    ref.watch(dataVersionProvider);
    final c = await ref.read(customerRepositoryProvider).byId(customerId);
    if (c == null) throw const Failure('This customer no longer exists.');
    final quotes = await ref.read(quoteRepositoryProvider).byCustomer(customerId);
    return CustomerDetailState(customer: c, quotes: quotes);
  }
}
