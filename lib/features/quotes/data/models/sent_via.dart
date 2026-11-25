/// Channel a quote was last sent through (recorded when sending is added).
enum SentVia {
  sms('Text'),
  email('Email');

  const SentVia(this.label);
  final String label;

  static SentVia? parse(Object? v) => SentVia.values.where((s) => s.name == '$v').firstOrNull;
}
