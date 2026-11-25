// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(smsComposer)
final smsComposerProvider = SmsComposerProvider._();

final class SmsComposerProvider
    extends $FunctionalProvider<SmsComposer, SmsComposer, SmsComposer>
    with $Provider<SmsComposer> {
  SmsComposerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smsComposerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smsComposerHash();

  @$internal
  @override
  $ProviderElement<SmsComposer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SmsComposer create(Ref ref) {
    return smsComposer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmsComposer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmsComposer>(value),
    );
  }
}

String _$smsComposerHash() => r'2a143898a0583fa636d22b970bca3fe2de41d7c2';
