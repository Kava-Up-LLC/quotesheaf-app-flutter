import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/errors/failure.dart';
import 'package:quote_generator_app/core/services/appambit_cms.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';
import 'package:quote_generator_app/features/business/data/models/business_profile.dart';
import 'package:quote_generator_app/features/services/viewmodels/service_picker_viewmodel.dart';

import '../../helpers/fakes.dart';

void main() {
  test('categories, units and items all come from the CMS', () async {
    final container = ProviderContainer(overrides: [
      cmsServiceProvider.overrideWithValue(FakeCmsService(catalogCms)),
      dbServiceProvider.overrideWithValue(FakeDbService()),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(servicePickerViewModelProvider, (_, _) {});
    final s = await container.read(servicePickerViewModelProvider.future);

    // Inactive items and categories are hidden; categories keep CMS order and
    // only show when they have services.
    expect(s.services.map((x) => x.name), ['Contactor 30A', 'Refrigerant Recharge R-410A']);
    expect(s.categories, ['Refrigerant', 'Parts']);
    expect(s.stepFor(s.services.last), 0.5);
    expect(s.stepFor(s.services.first), 1);

    container.read(servicePickerViewModelProvider.notifier).setCategory('Parts');
    expect(container.read(servicePickerViewModelProvider).value!.visible.map((x) => x.name), ['Contactor 30A']);
    sub.close();
  });

  test('multi-select basket: + / − by CMS step, count, total, Selected filter', () async {
    final container = ProviderContainer(overrides: [
      cmsServiceProvider.overrideWithValue(FakeCmsService(catalogCms)),
      dbServiceProvider.overrideWithValue(FakeDbService()),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(servicePickerViewModelProvider, (_, _) {});
    final s0 = await container.read(servicePickerViewModelProvider.future);
    final vm = container.read(servicePickerViewModelProvider.notifier);
    final contactor = s0.services.first; // ea, step 1, $79
    final r410 = s0.services.last; // lb, step 0.5, $85

    vm
      ..increment(r410)
      ..increment(r410)
      ..increment(contactor)
      ..increment(r410);
    var s = container.read(servicePickerViewModelProvider).value!;
    expect(s.pickedCount, 2);
    expect(s.picked[r410.id]!.quantity, 1.5);
    expect(s.pickedTotal, 12750 + 7900);

    vm.showSelected();
    s = container.read(servicePickerViewModelProvider).value!;
    expect(s.visible.length, 2);

    vm.decrement(contactor);
    s = container.read(servicePickerViewModelProvider).value!;
    expect(s.pickedCount, 1);
    expect(s.selections.single.service.id, r410.id);
    expect(s.selections.single.quantity, 1.5);

    vm.decrement(r410);
    vm.decrement(r410);
    vm.decrement(r410);
    s = container.read(servicePickerViewModelProvider).value!;
    expect(s.pickedCount, 0);
    expect(s.selectedOnly, isFalse);
    sub.close();
  });

  test('business profile has no built-in values: missing CMS fields fail loudly', () {
    expect(() => BusinessProfile.fromJson({'name': 'Joe Plumbing'}),
        throwsA(isA<Failure>().having((f) => f.message, 'message', contains('tax_label'))));
    expect(BusinessProfile.fromJson(businessProfileJson).quotePrefix, 'Q-');
  });
}
