// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appambit_cms.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cmsService)
final cmsServiceProvider = CmsServiceProvider._();

final class CmsServiceProvider
    extends $FunctionalProvider<CmsService, CmsService, CmsService>
    with $Provider<CmsService> {
  CmsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cmsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cmsServiceHash();

  @$internal
  @override
  $ProviderElement<CmsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CmsService create(Ref ref) {
    return cmsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CmsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CmsService>(value),
    );
  }
}

String _$cmsServiceHash() => r'8eedf3e74341c09ee083ef0dd17c3edd517b7473';
