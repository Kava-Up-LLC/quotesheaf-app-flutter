// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_editor_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).

@ProviderFor(QuoteEditorViewModel)
final quoteEditorViewModelProvider = QuoteEditorViewModelFamily._();

/// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).
final class QuoteEditorViewModelProvider
    extends $AsyncNotifierProvider<QuoteEditorViewModel, QuoteEditorState> {
  /// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).
  QuoteEditorViewModelProvider._({
    required QuoteEditorViewModelFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'quoteEditorViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quoteEditorViewModelHash();

  @override
  String toString() {
    return r'quoteEditorViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  QuoteEditorViewModel create() => QuoteEditorViewModel();

  @override
  bool operator ==(Object other) {
    return other is QuoteEditorViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quoteEditorViewModelHash() =>
    r'6edcbddbda4304536dfdb2791d0d5c9e7fdefdd0';

/// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).

final class QuoteEditorViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          QuoteEditorViewModel,
          AsyncValue<QuoteEditorState>,
          QuoteEditorState,
          FutureOr<QuoteEditorState>,
          (String, String?)
        > {
  QuoteEditorViewModelFamily._()
    : super(
        retry: null,
        name: r'quoteEditorViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).

  QuoteEditorViewModelProvider call(String quoteKey, String? customerId) =>
      QuoteEditorViewModelProvider._(
        argument: (quoteKey, customerId),
        from: this,
      );

  @override
  String toString() => r'quoteEditorViewModelProvider';
}

/// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).

abstract class _$QuoteEditorViewModel extends $AsyncNotifier<QuoteEditorState> {
  late final _$args = ref.$arg as (String, String?);
  String get quoteKey => _$args.$1;
  String? get customerId => _$args.$2;

  FutureOr<QuoteEditorState> build(String quoteKey, String? customerId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<QuoteEditorState>, QuoteEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuoteEditorState>, QuoteEditorState>,
              AsyncValue<QuoteEditorState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
