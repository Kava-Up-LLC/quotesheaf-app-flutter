// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerDetailViewModel)
final customerDetailViewModelProvider = CustomerDetailViewModelFamily._();

final class CustomerDetailViewModelProvider
    extends
        $AsyncNotifierProvider<CustomerDetailViewModel, CustomerDetailState> {
  CustomerDetailViewModelProvider._({
    required CustomerDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customerDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerDetailViewModelHash();

  @override
  String toString() {
    return r'customerDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CustomerDetailViewModel create() => CustomerDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is CustomerDetailViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerDetailViewModelHash() =>
    r'2014e2ad3b4a5a74b1615ee78af4a792136113e7';

final class CustomerDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CustomerDetailViewModel,
          AsyncValue<CustomerDetailState>,
          CustomerDetailState,
          FutureOr<CustomerDetailState>,
          String
        > {
  CustomerDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'customerDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerDetailViewModelProvider call(String customerId) =>
      CustomerDetailViewModelProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerDetailViewModelProvider';
}

abstract class _$CustomerDetailViewModel
    extends $AsyncNotifier<CustomerDetailState> {
  late final _$args = ref.$arg as String;
  String get customerId => _$args;

  FutureOr<CustomerDetailState> build(String customerId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CustomerDetailState>, CustomerDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CustomerDetailState>, CustomerDetailState>,
              AsyncValue<CustomerDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
