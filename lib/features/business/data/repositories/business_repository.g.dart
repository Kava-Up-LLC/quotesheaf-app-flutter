// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessRepository)
final businessRepositoryProvider = BusinessRepositoryProvider._();

final class BusinessRepositoryProvider
    extends
        $FunctionalProvider<
          BusinessRepository,
          BusinessRepository,
          BusinessRepository
        >
    with $Provider<BusinessRepository> {
  BusinessRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessRepository create(Ref ref) {
    return businessRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessRepository>(value),
    );
  }
}

String _$businessRepositoryHash() =>
    r'1f5fcbcccd034db11c005daf833b0ed62d9b74aa';
