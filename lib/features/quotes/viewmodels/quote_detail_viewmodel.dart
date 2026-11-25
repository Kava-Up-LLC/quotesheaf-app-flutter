import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/data_version.dart';
import '../../../core/utils/money.dart';
import '../data/models/quote.dart';
import '../data/repositories/quote_repository.dart';

part 'quote_detail_viewmodel.g.dart';

class QuoteDetailState {
  const QuoteDetailState({required this.quote});

  final Quote quote;

  String get taxDisplay => '${quote.taxLabel} ${Money.formatRate(quote.taxRate)}%';
}

@riverpod
class QuoteDetailViewModel extends _$QuoteDetailViewModel {
  @override
  Future<QuoteDetailState> build(String quoteId) async {
    ref.watch(dataVersionProvider);
    final quote = await ref.read(quoteRepositoryProvider).byId(quoteId);
    if (quote == null) throw const Failure('This quote no longer exists.');
    return QuoteDetailState(quote: quote);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
