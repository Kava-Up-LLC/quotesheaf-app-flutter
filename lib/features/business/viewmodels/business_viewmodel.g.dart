// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BusinessViewModel)
final businessViewModelProvider = BusinessViewModelProvider._();

final class BusinessViewModelProvider
    extends $AsyncNotifierProvider<BusinessViewModel, BusinessState> {
  BusinessViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessViewModelHash();

  @$internal
  @override
  BusinessViewModel create() => BusinessViewModel();
}

String _$businessViewModelHash() => r'466a82418dadf1efe02a9e04ec749c9d4c2e65d0';

abstract class _$BusinessViewModel extends $AsyncNotifier<BusinessState> {
  FutureOr<BusinessState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BusinessState>, BusinessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BusinessState>, BusinessState>,
              AsyncValue<BusinessState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
