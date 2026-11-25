// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_picker_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServicePickerViewModel)
final servicePickerViewModelProvider = ServicePickerViewModelProvider._();

final class ServicePickerViewModelProvider
    extends $AsyncNotifierProvider<ServicePickerViewModel, ServicePickerState> {
  ServicePickerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicePickerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicePickerViewModelHash();

  @$internal
  @override
  ServicePickerViewModel create() => ServicePickerViewModel();
}

String _$servicePickerViewModelHash() =>
    r'ee0078a1c10cc05d8826efbcbb69ae4896c5d890';

abstract class _$ServicePickerViewModel
    extends $AsyncNotifier<ServicePickerState> {
  FutureOr<ServicePickerState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ServicePickerState>, ServicePickerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ServicePickerState>, ServicePickerState>,
              AsyncValue<ServicePickerState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
