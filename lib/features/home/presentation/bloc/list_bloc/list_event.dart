part of 'list_bloc.dart';

sealed class ListEvent {}

class AddItemsManually extends ListEvent {
  final String input;
  AddItemsManually(this.input);
}

class RemoveItem extends ListEvent {
  final GroceryItem item;
  RemoveItem(this.item);
}

class UndoRemove extends ListEvent {
  final int index;
  final GroceryItem item;
  UndoRemove(this.index, this.item);
}

class UpdateAmount extends ListEvent {
  final GroceryItem item;
  final double amount;
  UpdateAmount(this.item, this.amount);
}

class UpdateUnit extends ListEvent {
  final GroceryItem item;
  final UnitOfMeasure unit;
  UpdateUnit(this.item, this.unit);
}

class UpdateCategory extends ListEvent {
  final GroceryItem item;
  final GroceryCategory groceryCategory;
  UpdateCategory(this.item, this.groceryCategory);
}

class UpdatePrice extends ListEvent {
  final GroceryItem item;
  final double price;
  UpdatePrice(this.item, this.price);
}

class ClearAllItems extends ListEvent {}

class AddMultipleItems extends ListEvent {
  final List<GroceryItem> items;
  final bool isAiGenerated;
  final bool isSuggestion;
  AddMultipleItems({
    required this.items,
    required this.isAiGenerated,
    required this.isSuggestion,
  });
}

class RestoreItemsEvent extends ListEvent {
  final List<GroceryItem> items;
  RestoreItemsEvent(this.items);
}

class ToggleCheckedEvent extends ListEvent {
  final String itemId;
  final bool isChecked;

  ToggleCheckedEvent(this.itemId, this.isChecked);
}
