import 'package:grocerai/features/home/domain/grocery_category.dart';
import 'package:grocerai/features/home/domain/unit_of_measure.dart';
import 'package:uuid/uuid.dart';
import '../domain/grocery.dart';

class GroceryRepository {
  final _uuid = const Uuid();

  List<GroceryItem> parseRawInput(String input, List<GroceryItem> currentItems) {
    final List<GroceryItem> newList = List.from(currentItems);

    final rawNames = input
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty);

    for (final name in rawNames) {
      final exists = newList.any(
            (item) => item.name.toLowerCase() == name.toLowerCase(),
      );

      if (!exists) {
        newList.insert(0, _createNewItem(name));
      }
    }

    return newList..sort((a, b) => (a.category.displayName).compareTo(b.category.displayName));
  }

  GroceryItem _createNewItem(String name) {
    return GroceryItem(
      id: _uuid.v4(),
      name: name,
      quantity: 1.0,
      unitOfMeasure: UnitOfMeasure.pcs,
      category: GroceryCategory.other,
      isChecked: false,
      isSuggestion: false,
    );
  }
}