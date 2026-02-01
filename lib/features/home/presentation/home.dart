import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/core/constants.dart';
import 'package:grocerai/features/auth/presentation/bloc/login_form_bloc/login_form_bloc.dart';
import 'package:grocerai/features/home/domain/ai_operation.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/features/home/domain/grocery_category.dart';
import 'package:grocerai/features/home/domain/unit_of_measure.dart';
import 'package:grocerai/features/home/presentation/bloc/ai_generated_list_bloc/ai_generated_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/archive_bloc/archive_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/list_bloc/list_bloc.dart';
import 'package:grocerai/features/home/presentation/cubit/user_name_cubit.dart';
import 'package:grocerai/features/home/presentation/history.dart';
import 'package:grocerai/features/home/presentation/widgets/price_input.dart';
import 'package:grocerai/features/home/presentation/widgets/price_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  final ValueNotifier<int?> _selectedItemNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _selectedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiGeneratedBloc, AiGeneratedState>(
      listener: (context, state) {
        if (state is AiGeneratedLoaded && state.operation == AiOperation.recipe) {
          context.read<ListBloc>().add(
            AddMultipleItems(
              items: state.items,
              isAiGenerated: true,
              isSuggestion: false,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingredients added to your list!")),
          );
        }
        if (state is AiGeneratedError && state.operation == AiOperation.recipe) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is AiGeneratedLoaded && state.operation == AiOperation.restock) {
          context.read<ListBloc>().add(
            AddMultipleItems(
              items: state.items,
              isAiGenerated: false,
              isSuggestion: true,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Some suggestions for restock added to your list!")),
          );
        }
        if (state is AiGeneratedError && state.operation == AiOperation.restock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: BlocBuilder<ListBloc, ListState>(
        builder: (context, state) {
          return Scaffold(
            drawer: Drawer(
              width: 300,
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.deepGreen, AppColors.accentGreen],
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryGreen,
                        size: 40,
                      ),
                    ),
                    accountName: const Text(
                      "Grocery User",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      FirebaseAuth.instance.currentUser?.email ?? "User Email",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        context.read<LoginFormBloc>().add(SignOut());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sign Out",
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.deepGreen, AppColors.accentGreen],
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'View History',
                  onPressed: () {
                    Navigator.push<List<GroceryItem>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fact_check_outlined),
                  tooltip: 'Finish & Archive Trip',
                  onPressed: () =>
                      _showArchiveDialog(state.items, state.total, context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearConfirmation(context),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 15),
                        BlocBuilder<UserProfileCubit, UserProfileState>(
                          builder: (context, state) {
                            String displayName = "Shopper";

                            if (state is UserProfileLoaded) {
                              displayName = state.displayName;
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Good Day, $displayName!",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: AppColors.deepGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "January 21, 2026",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    state.items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final grocery = state.items[index];
                              final showHeader =
                                  index == 0 ||
                                  grocery.category !=
                                      state.items[index - 1].category;
                              return ValueListenableBuilder(
                                valueListenable: _selectedItemNotifier,
                                builder: (context, selectedIndex, child) {
                                  final isSelected = selectedIndex == index;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showHeader)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            top: 20.0,
                                            bottom: 8.0,
                                          ),
                                          child: Text(
                                            grocery.category.displayName
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple.shade700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      Dismissible(
                                        key: Key(state.items[index].id),
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onDismissed: (direction) {
                                          final deletedItem =
                                              state.items[index];
                                          final int deletedIndex = index;

                                          final listBloc = context
                                              .read<ListBloc>();

                                          listBloc.add(RemoveItem(deletedItem));

                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${deletedItem.name} removed",
                                              ),
                                              action: SnackBarAction(
                                                label: "UNDO",
                                                onPressed: () {
                                                  listBloc.add(
                                                    UndoRemove(
                                                      deletedIndex,
                                                      deletedItem,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_selectedItemNotifier.value ==
                                                index) {
                                              _selectedItemNotifier.value =
                                                  null;
                                            } else {
                                              _selectedItemNotifier.value =
                                                  index;
                                            }
                                          },
                                          child: Container(
                                            color: grocery.isSuggestion
                                                ? Colors.deepPurple.withOpacity(
                                                    0.05,
                                                  )
                                                : (isSelected
                                                      ? Colors.green.shade100
                                                      : Colors.transparent),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (isSelected)
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                    Checkbox(
                                                      value: grocery.isChecked,
                                                      onChanged: (val) => context
                                                          .read<ListBloc>()
                                                          .add(
                                                            ToggleCheckedEvent(
                                                              grocery.id,
                                                              val ?? false,
                                                            ),
                                                          ),
                                                    ),

                                                    Expanded(
                                                      child: SizedBox(
                                                        width: 70,
                                                        child: Text(
                                                          grocery.name,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            decoration:
                                                                grocery
                                                                    .isChecked
                                                                ? TextDecoration
                                                                      .lineThrough
                                                                : null,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      width: 50,
                                                      child: TextFormField(
                                                        initialValue: grocery
                                                            .quantity
                                                            .toString(),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            const InputDecoration(
                                                              isDense: true,
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                            ),
                                                        onChanged: (val) {
                                                          context
                                                              .read<ListBloc>()
                                                              .add(
                                                                UpdateAmount(
                                                                  grocery,
                                                                  double.tryParse(
                                                                        val,
                                                                      ) ??
                                                                      1.0,
                                                                ),
                                                              );
                                                        },
                                                      ),
                                                    ),

                                                    DropdownButton<
                                                      UnitOfMeasure
                                                    >(
                                                      value:
                                                          grocery.unitOfMeasure,
                                                      underline: Container(),
                                                      alignment:
                                                          Alignment.center,
                                                      items: UnitOfMeasure.values.map((
                                                        UnitOfMeasure unitValue,
                                                      ) {
                                                        return DropdownMenuItem<
                                                          UnitOfMeasure
                                                        >(
                                                          value: unitValue,
                                                          child: Text(
                                                            unitValue.name,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (
                                                            UnitOfMeasure?
                                                            newValue,
                                                          ) {
                                                            if (newValue !=
                                                                null) {
                                                              // 3. Pass the Enum directly to the Bloc
                                                              context
                                                                  .read<
                                                                    ListBloc
                                                                  >()
                                                                  .add(
                                                                    UpdateUnit(
                                                                      grocery,
                                                                      newValue,
                                                                    ),
                                                                  );
                                                            }
                                                          },
                                                    ),

                                                    SizedBox(
                                                      width: 70,
                                                      child: DropdownButton<GroceryCategory>(
                                                        value: grocery.category,
                                                        alignment:
                                                            Alignment.center,
                                                        underline: Container(),
                                                        isExpanded: true,
                                                        items: GroceryCategory.values.map((
                                                          GroceryCategory
                                                          groceryCategory,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            GroceryCategory
                                                          >(
                                                            value:
                                                                groceryCategory,
                                                            child: Text(
                                                              groceryCategory
                                                                  .displayName,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged:
                                                            (
                                                              GroceryCategory?
                                                              groceryCategory,
                                                            ) {
                                                              context
                                                                  .read<
                                                                    ListBloc
                                                                  >()
                                                                  .add(
                                                                    UpdateCategory(
                                                                      grocery,
                                                                      groceryCategory!,
                                                                    ),
                                                                  );
                                                            },
                                                      ),
                                                    ),
                                                    PriceInput(item: grocery),
                                                  ],
                                                ),
                                                if (grocery.isSuggestion &&
                                                    grocery.aiReason != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 48.0,
                                                          bottom: 8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.auto_awesome,
                                                          size: 12,
                                                          color:
                                                              Colors.deepPurple,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          grocery.aiReason!,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: Colors
                                                                .deepPurple
                                                                .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                    if (state.items.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Estimated Total",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${state.total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.edit_note, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Quick Add Items',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _controller,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: 'Enter grocery item(s)',
                              hintText: 'Milk, Eggs, Bread...',
                              helperText:
                                  'Tip: Use commas to add multiple items at once',
                              helperStyle: TextStyle(color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    size: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    context.read<ListBloc>().add(
                                      AddItemsManually(_controller.text),
                                    );
                                    _controller.clear();
                                  },
                                ),
                              ),
                            ),
                            onFieldSubmitted: (text) {
                              _controller.clear();
                              context.read<ListBloc>().add(
                                AddItemsManually(text),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Generated List',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recipeController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: 'Enter a dish or recipe',
                              hintText: 'e.g., Spaghetti Bolognese',
                              helperText:
                                  'Tip: Add a recipe per request for best results',
                              helperStyle: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.deepPurple.shade100,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (text) {
                              context.read<AiGeneratedBloc>().add(
                                GenerateFromRecipe(_recipeController.text),
                              );
                              _recipeController.clear();
                            },
                          ),
                          const SizedBox(height: 12),

                          BlocBuilder<AiGeneratedBloc, AiGeneratedState>(
                            builder: (context, state) {
                              return Container(
                                width: double.infinity,
                                height: 55,
                                // Set a fixed height so the container doesn't jump/resize when switching to the loader
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.deepGreen,
                                      AppColors.accentGreen,
                                    ],
                                  ),
                                ),
                                child:
                                    state is AiGeneratedLoading &&
                                        state.operation == AiOperation.recipe
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () {
                                          context.read<AiGeneratedBloc>().add(
                                            GenerateFromRecipe(
                                              _recipeController.text,
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.bolt,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Generate Grocery List",
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          // Removed vertical padding here because height is now controlled by the Container
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Smart Budgeting',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  if (_selectedItemNotifier.value == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please tap an item on the list first!",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final result = await Navigator.push<double>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PriceScannerPage(),
                                    ),
                                  );

                                  if (result != null) {
                                    int index = _selectedItemNotifier.value!;
                                    final groceryItem = context
                                        .read<ListBloc>()
                                        .state
                                        .items[index];
                                    context.read<ListBloc>().add(
                                      UpdatePrice(groceryItem, result),
                                    );
                                    _selectedItemNotifier.value = null;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "SCAN PRICE TAG",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              BlocBuilder<AiGeneratedBloc, AiGeneratedState>(
                                builder: (context, state) {
                                  return Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.deepPurple.shade300,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child:
                                        state is AiGeneratedLoading &&
                                            state.operation ==
                                                AiOperation.restock
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : TextButton.icon(
                                            onPressed: () => context
                                                .read<AiGeneratedBloc>()
                                                .add(
                                                  GenerateSmartRestockSuggestions(),
                                                ),
                                            icon: const Icon(
                                              Icons.psychology,
                                              color: Colors.deepPurple,
                                            ),
                                            label: const Text(
                                              "Smart Restock Suggestions",
                                            ),
                                          ),
                                  );
                                },
                              ), // Bottom padding for breathing room
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showArchiveDialog(
    List<GroceryItem> item,
    double total,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finish Shopping?"),
        content: Text(
          "This will save your list (Total: \$${total.toStringAsFixed(2)}) to history and clear your current screen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Not yet"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ArchiveBloc>().add(
                ArchiveListRequested(item, total),
              );
            },
            child: const Text("Save & Clear"),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear List?"),
          content: const Text(
            "This will remove all items from your grocery list.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<ListBloc>().add(ClearAllItems());
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                "Clear All",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 100,
              color: AppColors.accentGreen,
            ),
            const SizedBox(height: 10),
            Text(
              "Your list is empty",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add items manually below or let AI suggest a recipe for you!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
