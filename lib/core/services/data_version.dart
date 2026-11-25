import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_version.g.dart';

/// Bumped by repositories after every DB write so list/detail ViewModels
/// that watch it reload automatically.
@Riverpod(keepAlive: true)
class DataVersion extends _$DataVersion {
  @override
  int build() => 0;

  void bump() => state++;
}
