// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_form_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Register (customerId == null) or edit a customer.

@ProviderFor(CustomerFormViewModel)
final customerFormViewModelProvider = CustomerFormViewModelFamily._();

/// Register (customerId == null) or edit a customer.
final class CustomerFormViewModelProvider
    extends $AsyncNotifierProvider<CustomerFormViewModel, CustomerFormState> {
  /// Register (customerId == null) or edit a customer.
  CustomerFormViewModelProvider._({
    required CustomerFormViewModelFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'customerFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerFormViewModelHash();

  @override
  String toString() {
    return r'customerFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CustomerFormViewModel create() => CustomerFormViewModel();

  @override
  bool operator ==(Object other) {
    return other is CustomerFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerFormViewModelHash() =>
    r'0bf8dbfc418aeb399eb54817b822f873a9ee054d';

/// Register (customerId == null) or edit a customer.

final class CustomerFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CustomerFormViewModel,
          AsyncValue<CustomerFormState>,
          CustomerFormState,
          FutureOr<CustomerFormState>,
          String?
        > {
  CustomerFormViewModelFamily._()
    : super(
        retry: null,
        name: r'customerFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Register (customerId == null) or edit a customer.

  CustomerFormViewModelProvider call(String? customerId) =>
      CustomerFormViewModelProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerFormViewModelProvider';
}

/// Register (customerId == null) or edit a customer.

abstract class _$CustomerFormViewModel
    extends $AsyncNotifier<CustomerFormState> {
  late final _$args = ref.$arg as String?;
  String? get customerId => _$args;

  FutureOr<CustomerFormState> build(String? customerId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CustomerFormState>, CustomerFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CustomerFormState>, CustomerFormState>,
              AsyncValue<CustomerFormState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
