/// One payment option printed in the PDF footer (CMS `payment_method`).
class PaymentMethod {
  const PaymentMethod({required this.label, required this.value});

  final String label;
  final String value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  static PaymentMethod? fromJson(Map<String, dynamic> j) {
    final label = '${j['label'] ?? ''}'.trim();
    final value = '${j['value'] ?? ''}'.trim();
    if (label.isEmpty || value.isEmpty) return null;
    return PaymentMethod(label: label, value: value);
  }
}

/// PDF footer: heading + note (CMS `quote_footer`) and payment columns.
class QuoteFooter {
  const QuoteFooter({this.title, this.note, this.methods = const []});

  final String? title;

  /// May contain `{{number}}`, replaced with the quote number on the PDF.
  final String? note;
  final List<PaymentMethod> methods;

  bool get isEmpty => title == null && methods.isEmpty;
}
