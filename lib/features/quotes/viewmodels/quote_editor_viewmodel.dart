import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failure.dart';
import '../../../core/router/routes.dart';
import '../../../core/services/analytics.dart';
import '../../../core/utils/money.dart';
import '../../business/data/repositories/business_repository.dart';
import '../../customers/data/models/customer.dart';
import '../../customers/data/repositories/customer_repository.dart';
import '../../services/data/models/service.dart';
import '../../services/data/repositories/service_repository.dart';
import '../data/models/business_snapshot.dart';
import '../data/models/line_item.dart';
import '../data/models/quote.dart';
import '../data/repositories/quote_repository.dart';

part 'quote_editor_viewmodel.g.dart';

class QuoteEditorState {
  const QuoteEditorState({
    this.quoteId,
    this.number,
    required this.numberPrefix,
    required this.issueDate,
    required this.validUntil,
    required this.business,
    required this.taxLabel,
    required this.taxRate,
    this.taxName,
    required this.catalog,
    this.customer,
    this.lines = const [],
    this.dirty = false,
    this.saving = false,
    this.savingForPreview = false,
    this.error,
  });

  /// Null until the quote is saved for the first time.
  final String? quoteId;

  /// Assigned by the DB on first save.
  final String? number;
  final String numberPrefix;
  final DateTime issueDate;
  final DateTime validUntil;
  final BusinessSnapshot business;
  final String taxLabel;
  final double taxRate;
  final String? taxName;

  /// CMS catalog (units drive the quantity step when editing a line).
  final Catalog catalog;
  final Customer? customer;
  final List<LineItem> lines;
  final bool dirty;
  final bool saving;

  /// Which button shows the spinner while [saving].
  final bool savingForPreview;
  final String? error;

  bool get isNew => quoteId == null;
  QuoteTotals get totals => QuoteTotals.of(lines, taxRate);

  /// "GET 4.5%"
  String get taxDisplay => '$taxLabel ${Money.formatRate(taxRate)}%';

  double stepFor(LineItem l) => catalog.stepFor(l.unit);

  bool get canSave => customer != null && !saving;
  bool get canPreview => customer != null && lines.isNotEmpty && !saving;

  QuoteEditorState copyWith({
    String? quoteId,
    String? number,
    Customer? customer,
    List<LineItem>? lines,
    bool? dirty,
    bool? saving,
    bool? savingForPreview,
    String? Function()? error,
  }) =>
      QuoteEditorState(
        quoteId: quoteId ?? this.quoteId,
        number: number ?? this.number,
        numberPrefix: numberPrefix,
        issueDate: issueDate,
        validUntil: validUntil,
        business: business,
        taxLabel: taxLabel,
        taxRate: taxRate,
        taxName: taxName,
        catalog: catalog,
        customer: customer ?? this.customer,
        lines: lines ?? this.lines,
        dirty: dirty ?? this.dirty,
        saving: saving ?? this.saving,
        savingForPreview: savingForPreview ?? this.savingForPreview,
        error: error != null ? error() : this.error,
      );
}

/// Editor for a new quote ([quoteKey] = `new`) or an existing one (its id).
@riverpod
class QuoteEditorViewModel extends _$QuoteEditorViewModel {
  @override
  Future<QuoteEditorState> build(String quoteKey, String? customerId) async {
    final catalog = await ref.read(serviceRepositoryProvider).catalog();
    final profile = await ref.read(businessRepositoryProvider).profile();

    if (quoteKey != AppRoutes.newQuoteKey) {
      final q = await ref.read(quoteRepositoryProvider).byId(quoteKey);
      if (q == null) throw const Failure('This quote no longer exists.');
      return QuoteEditorState(
        quoteId: q.id,
        number: q.number,
        numberPrefix: profile.quotePrefix,
        issueDate: q.issueDate,
        validUntil: q.validUntil,
        business: q.business,
        taxLabel: q.taxLabel,
        taxRate: q.taxRate,
        taxName: q.taxName,
        catalog: catalog,
        customer: q.customer,
        lines: q.lines,
      );
    }

    // New quote: snapshot the CMS profile + footer. The number is assigned when it is saved.
    final footer = await ref.read(businessRepositoryProvider).footer();
    final customer = customerId == null ? null : await ref.read(customerRepositoryProvider).byId(customerId);
    final today = DateTime.now();
    final issue = DateTime(today.year, today.month, today.day);
    return QuoteEditorState(
      numberPrefix: profile.quotePrefix,
      issueDate: issue,
      validUntil: issue.add(Duration(days: profile.validDays)),
      business: BusinessSnapshot(
        name: profile.name,
        tradeLabel: profile.tradeLabel,
        logo: profile.logoUrl,
        licenseNo: profile.licenseNo,
        phone: profile.phone,
        email: profile.email,
        address: profile.address,
        approvalNote: profile.approvalNote?.replaceAll('{{business_phone}}', profile.phone ?? ''),
        footerTitle: footer.title,
        footerNote: footer.note,
        paymentMethods: footer.methods,
      ),
      taxLabel: profile.taxLabel,
      taxRate: profile.taxRate,
      taxName: profile.taxName,
      catalog: catalog,
      customer: customer,
      dirty: customer != null,
    );
  }

  QuoteEditorState? get _s => state.value;

  void _set(QuoteEditorState s) => state = AsyncData(s);

  void setCustomer(Customer c) {
    final s = _s;
    if (s != null) _set(s.copyWith(customer: c, dirty: true, error: () => null));
  }

  /// Appends the services picked in Add services (in pick order).
  void addServices(List<ServiceSelection> picked) {
    final s = _s;
    if (s == null || picked.isEmpty) return;
    final lines = [
      for (final sel in picked)
        LineItem(
          id: const Uuid().v4(),
          serviceId: sel.service.id,
          name: sel.service.name,
          description: sel.description.isEmpty ? null : sel.description,
          unitPrice: sel.unitPrice,
          quantity: sel.quantity,
          unit: sel.service.unit,
          taxable: sel.taxable,
        ),
    ];
    _set(s.copyWith(lines: [...s.lines, ...lines], dirty: true, error: () => null));
  }

  void updateLine(String id,
      {required String description, required double quantity, required int unitPrice, required bool taxable}) {
    final s = _s;
    if (s == null) return;
    _set(s.copyWith(
      lines: [
        for (final l in s.lines)
          l.id == id
              ? l.copyWith(
                  description: description, quantity: quantity, unitPrice: unitPrice, taxable: taxable)
              : l,
      ],
      dirty: true,
    ));
  }

  /// Removes a line; returns its index so the View can offer Undo.
  int removeLine(String id) {
    final s = _s;
    if (s == null) return -1;
    final i = s.lines.indexWhere((l) => l.id == id);
    if (i < 0) return -1;
    _set(s.copyWith(lines: [...s.lines]..removeAt(i), dirty: true));
    return i;
  }

  void restoreLine(int index, LineItem line) {
    final s = _s;
    if (s == null) return;
    _set(s.copyWith(lines: [...s.lines]..insert(index.clamp(0, s.lines.length), line), dirty: true));
  }

  /// Saves to the DB. Returns the quote id, or null on failure (the error is
  /// kept in state). Skips the write if nothing changed.
  Future<String?> save({bool forPreview = false}) async {
    final s = _s;
    if (s == null || s.customer == null) return null;
    if (!s.dirty && s.quoteId != null) return s.quoteId;
    _set(s.copyWith(saving: true, savingForPreview: forPreview, error: () => null));
    try {
      final repo = ref.read(quoteRepositoryProvider);
      final id = await repo.save(QuoteDraft(
        id: s.quoteId,
        numberPrefix: s.numberPrefix,
        customerId: s.customer!.id,
        issueDate: s.issueDate,
        validUntil: s.validUntil,
        business: s.business,
        taxLabel: s.taxLabel,
        taxRate: s.taxRate,
        taxName: s.taxName,
        lines: s.lines,
      ));
      final number = s.number ?? await repo.numberOf(id);
      ref.read(analyticsServiceProvider).track(s.isNew ? 'quote_created' : 'quote_updated', {'number': number});
      if (ref.mounted) {
        _set(_s!.copyWith(quoteId: id, number: number, saving: false, dirty: false));
      }
      return id;
    } catch (e) {
      if (ref.mounted) {
        _set(_s!.copyWith(saving: false, error: () => e is Failure ? e.message : Failure.saveFailed));
      }
      return null;
    }
  }
}
