import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/data_version.dart';
import '../../business/data/repositories/business_repository.dart';
import '../data/models/quote.dart';
import '../data/repositories/quote_repository.dart';

part 'quotes_list_viewmodel.g.dart';

class QuotesListState {
  const QuotesListState({required this.quotes, required this.businessName, this.query = ''});

  final List<Quote> quotes;
  final String businessName;
  final String query;

  bool get isEmpty => quotes.isEmpty;

  /// Quotes matching the search (customer name, phone or number), A–Z by customer.
  List<Quote> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return quotes;
    final digits = q.replaceAll(RegExp(r'\D'), '');
    return quotes
        .where((x) =>
            x.customerName.toLowerCase().contains(q) ||
            x.number.toLowerCase().contains(q) ||
            (digits.length >= 3 && (x.customerPhone ?? '').contains(digits)))
        .toList();
  }
}

@riverpod
class QuotesListViewModel extends _$QuotesListViewModel {
  @override
  Future<QuotesListState> build() async {
    ref.watch(dataVersionProvider);
    final (quotes, profile) =
        await (ref.read(quoteRepositoryProvider).all(), ref.read(businessRepositoryProvider).profile()).wait;
    return QuotesListState(quotes: quotes, businessName: profile.shortName, query: state.value?.query ?? '');
  }

  void setQuery(String q) {
    final s = state.value;
    if (s != null) state = AsyncData(QuotesListState(quotes: s.quotes, businessName: s.businessName, query: q));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
