// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emailComposer)
final emailComposerProvider = EmailComposerProvider._();

final class EmailComposerProvider
    extends $FunctionalProvider<EmailComposer, EmailComposer, EmailComposer>
    with $Provider<EmailComposer> {
  EmailComposerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailComposerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailComposerHash();

  @$internal
  @override
  $ProviderElement<EmailComposer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmailComposer create(Ref ref) {
    return emailComposer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailComposer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailComposer>(value),
    );
  }
}

String _$emailComposerHash() => r'42bbaa9d8f6f312a1edff61f2f3ad5885e2e2462';
