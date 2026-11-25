import '../../../../core/services/appambit_db.dart';
import '../../../../core/utils/validators.dart';

/// A registered customer (DB `customers`).
class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.createdAt,
    this.quoteCount = 0,
  });

  final String id;
  final String name;

  /// E.164, e.g. +18085551234.
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  /// Filled by list queries only.
  final int quoteCount;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory Customer.fromRow(DbRow r) => Customer(
        id: '${r['id']}',
        name: '${r['name'] ?? ''}',
        phone: _blankToNull(r['phone']),
        email: _blankToNull(r['email']),
        address: _blankToNull(r['address']),
        notes: _blankToNull(r['notes']),
        createdAt: DbValue.asDate(r['created_at']) ?? DateTime.now(),
        quoteCount: DbValue.asInt(r['quote_count']),
      );

  static String? _blankToNull(Object? v) => v == null || '$v'.trim().isEmpty ? null : '$v';
}

/// Raw form input for registering / editing a customer.
class CustomerInput {
  const CustomerInput({required this.name, this.phone = '', this.email = '', this.address = '', this.notes = ''});

  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;

  String get normalizedPhone => Validators.normalizePhone(phone.trim());
  String get normalizedEmail => email.trim().toLowerCase();

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty && email.trim().isEmpty;

  /// Field → error message. Only the name is required; phone and email are
  /// optional but must be valid when given. Empty map = valid.
  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'Enter a name';
    final p = normalizedPhone;
    final e = normalizedEmail;
    if (p.isNotEmpty && !Validators.isE164(p)) errors['phone'] = 'Use international format, e.g. +1 808 555 1234';
    if (e.isNotEmpty && !Validators.isEmail(e)) errors['email'] = 'Enter a valid email';
    return errors;
  }
}
