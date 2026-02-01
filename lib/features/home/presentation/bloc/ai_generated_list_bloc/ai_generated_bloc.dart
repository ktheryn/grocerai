import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocerai/features/home/data/ai_grocery_repository.dart';
import 'package:grocerai/features/home/domain/ai_operation.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/locator.dart';

part 'ai_generated_event.dart';
part 'ai_generated_state.dart';

class AiGeneratedBloc extends Bloc<AiGeneratedEvent, AiGeneratedState> {
  AiGeneratedBloc() : super(AiGeneratedInitial(AiOperation.none)) {
    final aiGeneratedGroceryRepo = getIt<AIGeneratedGroceryRepository>();
    on<GenerateFromRecipe>((event, emit) async {
      emit(AiGeneratedLoading(AiOperation.recipe));
      try {
        final aiGeneratedGroceryItems = await aiGeneratedGroceryRepo.fetchAIGroceryList(event.recipeName);
        emit(AiGeneratedLoaded(items: aiGeneratedGroceryItems, operation: AiOperation.recipe));
      } catch (e) {
        emit(AiGeneratedError(errorMessage: e.toString(), operation: AiOperation.recipe));
      }
    });

    on<GenerateSmartRestockSuggestions>((event, emit) async {
      emit(AiGeneratedLoading(AiOperation.restock));
      try {
        final historyContext = await aiGeneratedGroceryRepo.getHistoryContext();

        if (historyContext.isEmpty) {
          emit(AiGeneratedError(errorMessage: "No purchase history found.", operation: AiOperation.restock));
          return;
        }
        final aiGeneratedGroceryItems = await aiGeneratedGroceryRepo.getSmartRestockSuggestions(historyContext);
        for (var item in aiGeneratedGroceryItems) {
          print('AI Suggested Item: ${item.name}, Reason: ${item.aiReason}');
        }
        emit(AiGeneratedLoaded(items: aiGeneratedGroceryItems, operation: AiOperation.restock));
      } catch (e) {
        emit(AiGeneratedError(errorMessage: e.toString(), operation: AiOperation.restock));
      }
    });
  }
}
