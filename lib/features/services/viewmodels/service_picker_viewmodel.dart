import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/money.dart';
import '../data/models/service.dart';
import '../data/repositories/service_repository.dart';

part 'service_picker_viewmodel.g.dart';

/// A service in the picker's basket, with its per-quote overrides.
class PickedItem {
  const PickedItem({required this.quantity, required this.description, required this.unitPrice, required this.taxable});

  final double quantity;
  final String description;

  /// Cents.
  final int unitPrice;
  final bool taxable;

  int get lineTotal => Money.lineTotal(unitPrice, quantity);

  PickedItem copyWith({double? quantity}) =>
      PickedItem(quantity: quantity ?? this.quantity, description: description, unitPrice: unitPrice, taxable: taxable);
}

class ServicePickerState {
  const ServicePickerState({
    required this.catalog,
    required this.recentIds,
    this.query = '',
    this.category,
    this.selectedOnly = false,
    this.picked = const {},
  });

  final Catalog catalog;
  final List<String> recentIds;
  final String query;

  /// Null = All.
  final String? category;

  /// "Selected" filter chip.
  final bool selectedOnly;

  /// Service id → basket item, in the order they were picked.
  final Map<String, PickedItem> picked;

  List<Service> get services => catalog.services;

  /// CMS categories that have at least one active service, in CMS order.
  List<String> get categories =>
      [for (final c in catalog.categories) if (services.any((s) => s.category == c.name)) c.name];

  double stepFor(Service s) => catalog.stepFor(s.unit);

  List<Service> get recent => [
        for (final id in recentIds) ...services.where((s) => s.id == id),
      ];

  int get pickedCount => picked.length;
  int get pickedTotal => picked.values.fold(0, (sum, p) => sum + p.lineTotal);

  List<Service> get visible {
    final q = query.trim().toLowerCase();
    return services.where((s) {
      if (selectedOnly && !picked.containsKey(s.id)) return false;
      if (category != null && s.category != category) return false;
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          (s.description ?? '').toLowerCase().contains(q) ||
          (s.sku ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// What goes back to the quote editor, in pick order.
  List<ServiceSelection> get selections => [
        for (final e in picked.entries)
          ServiceSelection(
            service: services.firstWhere((s) => s.id == e.key),
            description: e.value.description,
            quantity: e.value.quantity,
            unitPrice: e.value.unitPrice,
            taxable: e.value.taxable,
          ),
      ];

  ServicePickerState copyWith({
    String? query,
    String? Function()? category,
    bool? selectedOnly,
    Map<String, PickedItem>? picked,
  }) =>
      ServicePickerState(
        catalog: catalog,
        recentIds: recentIds,
        query: query ?? this.query,
        category: category != null ? category() : this.category,
        selectedOnly: selectedOnly ?? this.selectedOnly,
        picked: picked ?? this.picked,
      );
}

@riverpod
class ServicePickerViewModel extends _$ServicePickerViewModel {
  @override
  Future<ServicePickerState> build() async {
    final repo = ref.read(serviceRepositoryProvider);
    final (catalog, recent) = await (repo.catalog(), repo.recentServiceIds()).wait;
    return ServicePickerState(catalog: catalog, recentIds: recent);
  }

  ServicePickerState? get _s => state.value;

  void _set(ServicePickerState s) => state = AsyncData(s);

  void setQuery(String q) {
    final s = _s;
    if (s != null) _set(s.copyWith(query: q));
  }

  void setCategory(String? c) {
    final s = _s;
    if (s != null) _set(s.copyWith(category: () => c, selectedOnly: false));
  }

  void showSelected() {
    final s = _s;
    if (s != null) _set(s.copyWith(category: () => null, selectedOnly: true));
  }

  /// Adds one step of [service], or bumps its quantity if already picked.
  void increment(Service service) {
    final s = _s;
    if (s == null) return;
    final step = s.stepFor(service);
    final cur = s.picked[service.id];
    _set(s.copyWith(picked: {
      ...s.picked,
      service.id: cur?.copyWith(quantity: cur.quantity + step) ??
          PickedItem(
            quantity: step,
            description: service.description ?? '',
            unitPrice: service.unitPrice,
            taxable: service.taxable,
          ),
    }));
  }

  /// Lowers the quantity one step; removes the service at zero.
  void decrement(Service service) {
    final s = _s;
    final cur = s?.picked[service.id];
    if (s == null || cur == null) return;
    final next = cur.quantity - s.stepFor(service);
    final picked = {...s.picked};
    if (next <= 0) {
      picked.remove(service.id);
    } else {
      picked[service.id] = cur.copyWith(quantity: next);
    }
    // Leave the "Selected" filter once the basket is empty.
    _set(s.copyWith(picked: picked, selectedOnly: s.selectedOnly && picked.isNotEmpty));
  }

  /// Sets description / quantity / price / taxable from the item sheet.
  void setItem(Service service, PickedItem item) {
    final s = _s;
    if (s != null) _set(s.copyWith(picked: {...s.picked, service.id: item}));
  }
}
