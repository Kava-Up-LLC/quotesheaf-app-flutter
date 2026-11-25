// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appambit_db.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dbService)
final dbServiceProvider = DbServiceProvider._();

final class DbServiceProvider
    extends $FunctionalProvider<DbService, DbService, DbService>
    with $Provider<DbService> {
  DbServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dbServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dbServiceHash();

  @$internal
  @override
  $ProviderElement<DbService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DbService create(Ref ref) {
    return dbService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DbService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DbService>(value),
    );
  }
}

String _$dbServiceHash() => r'b00f8056cbd76fbce3423a7c0a7f492b9e8f56dc';
