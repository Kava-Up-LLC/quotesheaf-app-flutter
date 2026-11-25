// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_picker_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Choose an existing customer for a quote (registering is a separate screen).

@ProviderFor(CustomerPickerViewModel)
final customerPickerViewModelProvider = CustomerPickerViewModelProvider._();

/// Choose an existing customer for a quote (registering is a separate screen).
final class CustomerPickerViewModelProvider
    extends
        $AsyncNotifierProvider<CustomerPickerViewModel, CustomerPickerState> {
  /// Choose an existing customer for a quote (registering is a separate screen).
  CustomerPickerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerPickerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerPickerViewModelHash();

  @$internal
  @override
  CustomerPickerViewModel create() => CustomerPickerViewModel();
}

String _$customerPickerViewModelHash() =>
    r'4264d2b0c3b401d26c04ce1d9ff37a200cf20212';

/// Choose an existing customer for a quote (registering is a separate screen).

abstract class _$CustomerPickerViewModel
    extends $AsyncNotifier<CustomerPickerState> {
  FutureOr<CustomerPickerState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CustomerPickerState>, CustomerPickerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CustomerPickerState>, CustomerPickerState>,
              AsyncValue<CustomerPickerState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
