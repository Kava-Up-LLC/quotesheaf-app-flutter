// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quoteRepository)
final quoteRepositoryProvider = QuoteRepositoryProvider._();

final class QuoteRepositoryProvider
    extends
        $FunctionalProvider<QuoteRepository, QuoteRepository, QuoteRepository>
    with $Provider<QuoteRepository> {
  QuoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quoteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuoteRepository create(Ref ref) {
    return quoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuoteRepository>(value),
    );
  }
}

String _$quoteRepositoryHash() => r'9a4af8b6c71721c75a9e589f33482a5b9a3e2910';
