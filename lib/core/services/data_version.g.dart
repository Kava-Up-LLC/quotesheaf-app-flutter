// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_version.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bumped by repositories after every DB write so list/detail ViewModels
/// that watch it reload automatically.

@ProviderFor(DataVersion)
final dataVersionProvider = DataVersionProvider._();

/// Bumped by repositories after every DB write so list/detail ViewModels
/// that watch it reload automatically.
final class DataVersionProvider extends $NotifierProvider<DataVersion, int> {
  /// Bumped by repositories after every DB write so list/detail ViewModels
  /// that watch it reload automatically.
  DataVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataVersionHash();

  @$internal
  @override
  DataVersion create() => DataVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$dataVersionHash() => r'e1e4a1013164111c889f4e5b25f40e85ae90131e';

/// Bumped by repositories after every DB write so list/detail ViewModels
/// that watch it reload automatically.

abstract class _$DataVersion extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
