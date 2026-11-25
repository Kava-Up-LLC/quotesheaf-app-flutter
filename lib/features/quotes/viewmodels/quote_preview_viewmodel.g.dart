// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_preview_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuotePreviewViewModel)
final quotePreviewViewModelProvider = QuotePreviewViewModelFamily._();

final class QuotePreviewViewModelProvider
    extends $AsyncNotifierProvider<QuotePreviewViewModel, QuotePreviewState> {
  QuotePreviewViewModelProvider._({
    required QuotePreviewViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'quotePreviewViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quotePreviewViewModelHash();

  @override
  String toString() {
    return r'quotePreviewViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  QuotePreviewViewModel create() => QuotePreviewViewModel();

  @override
  bool operator ==(Object other) {
    return other is QuotePreviewViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quotePreviewViewModelHash() =>
    r'ddc0ca056e7ba44f85a2b9c35aaadd5c4210d02b';

final class QuotePreviewViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          QuotePreviewViewModel,
          AsyncValue<QuotePreviewState>,
          QuotePreviewState,
          FutureOr<QuotePreviewState>,
          String
        > {
  QuotePreviewViewModelFamily._()
    : super(
        retry: null,
        name: r'quotePreviewViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuotePreviewViewModelProvider call(String quoteId) =>
      QuotePreviewViewModelProvider._(argument: quoteId, from: this);

  @override
  String toString() => r'quotePreviewViewModelProvider';
}

abstract class _$QuotePreviewViewModel
    extends $AsyncNotifier<QuotePreviewState> {
  late final _$args = ref.$arg as String;
  String get quoteId => _$args;

  FutureOr<QuotePreviewState> build(String quoteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<QuotePreviewState>, QuotePreviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuotePreviewState>, QuotePreviewState>,
              AsyncValue<QuotePreviewState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
