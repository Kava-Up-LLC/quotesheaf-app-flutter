/// A user-facing failure raised by repositories/services.
class Failure implements Exception {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  static const saveFailed = "Couldn't save — check your connection.";
  static const loadFailed = "Couldn't load — check your connection.";

  @override
  String toString() => 'Failure($message${cause == null ? '' : ', $cause'})';
}
