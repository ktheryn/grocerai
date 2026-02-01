import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocerai/features/home/data/grocery_repository.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/features/home/domain/grocery_category.dart';
import 'package:grocerai/features/home/domain/unit_of_measure.dart';
import 'package:grocerai/locator.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(const ListState()) {
    final groceryRepository = getIt<GroceryRepository>();

    on<AddItemsManually>((event, emit) {
      final updatedList = groceryRepository.parseRawInput(
        event.input,
        state.items,
      );
      emit(state.copyWith(items: updatedList));
    });

    on<RemoveItem>((event, emit) {
      final updatedList = state.items.where((i) => i.id != event.item.id).toList();
      emit(state.copyWith(items: updatedList, total: _sumPrices(updatedList)));
    });

    on<UndoRemove>((event, emit) {
      if (state.items.any((i) => i.id == event.item.id)) return;

      final updatedList = List<GroceryItem>.from(state.items);
      final safeIndex = event.index.clamp(0, updatedList.length);
      updatedList.insert(safeIndex, event.item);

      emit(state.copyWith(items: updatedList, total: _sumPrices(updatedList)));
    });

    on<ClearAllItems>((event, emit) => emit(state.copyWith(items: [])));

    on<UpdateAmount>((event, emit) {
      final updatedList = state.items.map((item) {
        if (item.id == event.item.id) {
          return item.copyWith(amount: event.amount);
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updatedList));
    });

    on<UpdateUnit>((event, emit) {
      final updatedList = state.items.map((item) {
        if (item.id == event.item.id) {
          return item.copyWith(unit: event.unit);
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updatedList));
    });

    on<UpdateCategory>((event, emit) {
      final updatedList = state.items.map((item) {
        if (item.id == event.item.id) {
          return item.copyWith(category: event.groceryCategory);
        }
        return item;
      }).toList();

      updatedList.sort((a, b) => a.category.displayName.compareTo(b.category.displayName));

      emit(state.copyWith(items: updatedList));
    });

    on<UpdatePrice>((event, emit) {
      final updatedList = state.items.map((item) {
        if (item.id == event.item.id) {
          print({item.id});
          return item.copyWith(price: event.price);
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updatedList, total: _sumPrices(updatedList)));

    });

    on<AddMultipleItems>((event, emit) {
      final currentItems = List<GroceryItem>.from(state.items);

      for (var newItem in event.items) {
        bool alreadyExists = currentItems.any(
                (existing) => existing.name.toLowerCase() == newItem.name.toLowerCase()
        );

        if (!alreadyExists) {
          currentItems.insert(0, newItem.copyWith(isAiGenerated: true));
        }
      }

      emit(state.copyWith(items: currentItems));
    });

    on<RestoreItemsEvent>((event, emit) {
      emit(state.copyWith(items: event.items));
    });

    on<ToggleCheckedEvent>((event, emit) {
      final updatedItems = state.items.map((item) {
        if (item.id == event.itemId) {
          return item.copyWith(isChecked: event.isChecked);
        }
        return item;
      }).toList();

      emit(state.copyWith(items: updatedItems));
    });
  }
}

double _sumPrices(List<GroceryItem> items) {
  return items.fold(0, (sum, item) => sum + item.price);
}
