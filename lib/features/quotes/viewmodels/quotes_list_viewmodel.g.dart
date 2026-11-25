// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotes_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuotesListViewModel)
final quotesListViewModelProvider = QuotesListViewModelProvider._();

final class QuotesListViewModelProvider
    extends $AsyncNotifierProvider<QuotesListViewModel, QuotesListState> {
  QuotesListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesListViewModelHash();

  @$internal
  @override
  QuotesListViewModel create() => QuotesListViewModel();
}

String _$quotesListViewModelHash() =>
    r'3f4f831f0af8f27e49729a7beb2862203d6fcd29';

abstract class _$QuotesListViewModel extends $AsyncNotifier<QuotesListState> {
  FutureOr<QuotesListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QuotesListState>, QuotesListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuotesListState>, QuotesListState>,
              AsyncValue<QuotesListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
