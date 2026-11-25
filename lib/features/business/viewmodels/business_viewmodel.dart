import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/data_version.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money.dart';
import '../../services/data/repositories/service_repository.dart';
import '../data/models/business_profile.dart';
import '../data/models/quote_footer.dart';
import '../data/repositories/business_repository.dart';

part 'business_viewmodel.g.dart';

class BusinessState {
  const BusinessState({required this.profile, required this.footer, required this.serviceCount, required this.nextNumber});

  final BusinessProfile profile;
  final QuoteFooter footer;
  final int serviceCount;
  final String? nextNumber;

  String get taxDisplay => '${profile.taxLabel} ${Money.formatRate(profile.taxRate)}%';
}

@riverpod
class BusinessViewModel extends _$BusinessViewModel {
  @override
  Future<BusinessState> build() async {
    ref.watch(dataVersionProvider);
    final repo = ref.read(businessRepositoryProvider);
    final profile = await repo.profile(refresh: true);
    final services = (await ref.read(serviceRepositoryProvider).catalog(refresh: true)).services;
    String? next;
    try {
      next = Fmt.quoteNumber(profile.quotePrefix, await repo.nextQuoteValue());
    } catch (_) {
      next = null;
    }
    final footer = await repo.footer();
    return BusinessState(profile: profile, footer: footer, serviceCount: services.length, nextNumber: next);
  }
}
