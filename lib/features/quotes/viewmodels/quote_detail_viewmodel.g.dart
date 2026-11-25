// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuoteDetailViewModel)
final quoteDetailViewModelProvider = QuoteDetailViewModelFamily._();

final class QuoteDetailViewModelProvider
    extends $AsyncNotifierProvider<QuoteDetailViewModel, QuoteDetailState> {
  QuoteDetailViewModelProvider._({
    required QuoteDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'quoteDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quoteDetailViewModelHash();

  @override
  String toString() {
    return r'quoteDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  QuoteDetailViewModel create() => QuoteDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is QuoteDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quoteDetailViewModelHash() =>
    r'649b55c4ba28a95856e8b5f223070960b1ca70a5';

final class QuoteDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          QuoteDetailViewModel,
          AsyncValue<QuoteDetailState>,
          QuoteDetailState,
          FutureOr<QuoteDetailState>,
          String
        > {
  QuoteDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'quoteDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuoteDetailViewModelProvider call(String quoteId) =>
      QuoteDetailViewModelProvider._(argument: quoteId, from: this);

  @override
  String toString() => r'quoteDetailViewModelProvider';
}

abstract class _$QuoteDetailViewModel extends $AsyncNotifier<QuoteDetailState> {
  late final _$args = ref.$arg as String;
  String get quoteId => _$args;

  FutureOr<QuoteDetailState> build(String quoteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<QuoteDetailState>, QuoteDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuoteDetailState>, QuoteDetailState>,
              AsyncValue<QuoteDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
