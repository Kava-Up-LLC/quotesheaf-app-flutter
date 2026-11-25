// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomersListViewModel)
final customersListViewModelProvider = CustomersListViewModelProvider._();

final class CustomersListViewModelProvider
    extends $AsyncNotifierProvider<CustomersListViewModel, CustomersListState> {
  CustomersListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customersListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customersListViewModelHash();

  @$internal
  @override
  CustomersListViewModel create() => CustomersListViewModel();
}

String _$customersListViewModelHash() =>
    r'1539ab807c7a8a11f1824e3ca4fd31ac666519c8';

abstract class _$CustomersListViewModel
    extends $AsyncNotifier<CustomersListState> {
  FutureOr<CustomersListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CustomersListState>, CustomersListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CustomersListState>, CustomersListState>,
              AsyncValue<CustomersListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
