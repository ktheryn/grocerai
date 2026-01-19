import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/auth/presentation/bloc/login_form_bloc/login_form_bloc.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
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
  List<GroceryItem> _manualList = [];
  final List<String> _validUnits = [
    'pcs',
    'kg',
    'g',
    'lbs',
    'oz',
    'ml',
    'L',
    'box',
    'can',
  ];
  final List<String> _validCategories = [
    "Produce",
    "Dairy",
    "Bakery",
    "Meat",
    "Seafood",
    "Pantry",
    "Other",
  ];
  bool isReStockLoading = false;

  Future<List<GroceryItem>> addManualList() async {
    if (!_manualList.contains(_controller.text) &&
        _controller.text.isNotEmpty) {
      List<String> items = _controller.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      DateTime now = DateTime(2026, 1, 21);

      List<GroceryItem> newItems = items.map((name) {
        return GroceryItem(
          item: name,
          amount: 1.0,
          unit: 'pc',
          category: 'Other',
          isChecked: false,
          lastPurchased: now,
          isSuggestion: false,
        );
      }).toList();

      setState(() {
        for (var newItem in newItems) {
          bool alreadyExists = _manualList.any(
                (existing) =>
            existing.item.toLowerCase() == newItem.item.toLowerCase(),
          );

          if (!alreadyExists) {
            _manualList.insert(0, newItem);
          }
        }
        _manualList.sort((a, b) => a.category.compareTo(b.category));
        _controller.clear();
      });
    }

    return _manualList;
  }

  double get _totalPrice {
    return _manualList.fold(0, (sum, item) => sum + (item.price * item.amount));
  }

  Future<void> archiveCurrentList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_manualList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your list is empty!")),
      );
      return;
    }

    DateTime now = DateTime(2026, 1, 21);

    for (var item in _manualList) {
      if (item.isChecked) {
        if (item.lastPurchased != null) {
          int daysSinceLastPurchase = now.difference(item.lastPurchased!).inDays;
          item.frequencyDays = daysSinceLastPurchase;
        }
        item.lastPurchased = now;
      }
    }

    DateTime manualDate = DateTime(2026, 1, 21);
    final Map<String, dynamic> groceryHistoryEntry = {
      'timestamp': Timestamp.fromDate(manualDate),
      'totalSpent': _totalPrice,
      'items': _manualList.map((item) => item.toJson()).toList(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(groceryHistoryEntry);

      setState(() {
        _manualList.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("List Archived to History!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finish Shopping?"),
        content: Text("This will save your list (Total: \$${_totalPrice.toStringAsFixed(2)}) to history and clear your current screen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Not yet")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              archiveCurrentList();
            },
            child: const Text("Save & Clear"),
          ),
        ],
      ),
    );
  }

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  late final prompt =
  """
      Generate a grocery list for a recipe: ${_recipeController.text.trim()}. 
      Return the result as a JSON array of objects with the following keys:
      "item" (string), "amount" (number), "unit" (string), "category" (string).
     Provide the main ingredients on Do not include spices or condiments. ly and maximum of 8 items on the list. 
      Examples of categories are "Produce", "Dairy", "Bakery", "Meat", "Seafood", "Pantry", and "Other".
      Rules:
      - "amount" MUST be a number (e.g., 500, not "half").
      - "unit" should be kg, g, or pcs.
      - If a quantity is vague, default "amount" to 1.0.
      """;

  bool _isLoading = false;
  int? _selectedScanIndex;

  Future<void> generateWithAI() async {
    setState(() => _isLoading = true);

    if (_recipeController.text.isEmpty || _recipeController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe or dish name.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final List<dynamic> decodedData = jsonDecode(response.text!);

        final List<GroceryItem> aiItems = decodedData
            .map((item) => GroceryItem.fromJson(item))
            .toList();

        setState(() {
          for (var newItem in aiItems) {
            newItem.lastPurchased = DateTime.now();
            bool alreadyExists = _manualList.any(
                  (existing) =>
              existing.item.toLowerCase() == newItem.item.toLowerCase(),
            );

            if (!alreadyExists) {
              _manualList.insert(0, newItem);
            }
          }
          _manualList.sort((a, b) => a.category.compareTo(b.category));
          _recipeController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showClearConfirmation() {
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
                setState(() {
                  _manualList.clear();
                });
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

  Future<void> suggestRestockItems() async {
    setState(() => isReStockLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    // 1. Get history to give to the AI
    final historySnapshot = await FirebaseFirestore.instance
        .collection('users').doc(user?.uid).collection('history')
        .orderBy('timestamp', descending: true).limit(5).get();

    // 2. Prepare the context string
    String historyContext = historySnapshot.docs.map((doc) {
      return "Date: ${doc['timestamp'].toDate()}, Items: ${doc['items'].map((i) => i['item']).join(', ')}";
    }).join("\n");

    print('R1 ${historyContext}');

    // 3. Ask Gemini to be the "Agent"
    final prompt = """
  You are a Grocery Logic Agent. Your ONLY job is to analyze the provided purchase history and suggest 3-5 items the user needs to restock.

  STRICT RULES:
  1. ONLY suggest items that appear in the provided history.
  2. Do NOT suggest new items or recipe ingredients.
  3. Calculate the frequency of each item in the history.
  4. Compare the frequency to the current date: ${DateTime.now()}.
  5. If an item is "overdue" or "due soon" based on past dates, include it.
  6. "amount" MUST be a number (e.g., 500, not "half").
  7. "unit" should be kg, g, or pcs.
  8. If a quantity is vague, default "amount" to 1.0.
  9. Examples of categories are "Produce", "Dairy", "Bakery", "Meat", "Seafood", "Pantry", and "Other".

  User Purchase History:
  $historyContext

  Return a JSON array of objects with keys: 
  "item", "category", "amount", "unit", "aiReason".
""";

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final List<dynamic> suggestions = jsonDecode(response.text!);

      setState(() {
        for (var data in suggestions) {
          final item = GroceryItem.fromJson(data);
          item.isSuggestion = true; // POPULATED HERE
          item.aiReason = data['aiReason']; // POPULATED HERE

          // Only add if not already on the current list
          if (!_manualList.any((e) => e.item.toLowerCase() == item.item.toLowerCase())) {
            _manualList.insert(0, item);
          }
        }
      });
    } finally {
      setState(() => isReStockLoading = false);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          width: 300,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple.shade400),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurple.shade400, size: 40),
                ),
                accountName: const Text("Grocery User", style: TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? "User Email"),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    // Optional: Add a confirmation dialog before signing out
                    context.read<LoginFormBloc>().add(SignOut());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'View History',
              onPressed: () async {
                final List<GroceryItem>? restoredList = await Navigator.push<List<GroceryItem>>(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
      
                if (restoredList != null) {
                  setState(() {
                    _manualList = restoredList;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.fact_check_outlined),
              tooltip: 'Finish & Archive Trip',
              onPressed: () => _showArchiveDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearConfirmation,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _manualList.isEmpty ?  _buildEmptyState() : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _manualList.length,
                  itemBuilder: (context, index) {
                    final grocery = _manualList[index];
                    final isSelected = _selectedScanIndex == index;
                    bool showHeader = false;
                    if (index == 0) {
                      showHeader = true;
                    } else {
                      if (grocery.category != _manualList[index - 1].category) {
                        showHeader = true;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 20.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              grocery.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            // 1. Save a reference to the item and its index
                            final deletedItem = _manualList[index];
                            final int deletedIndex = index;
      
                            // 2. Remove from the list
                            setState(() {
                              _manualList.removeAt(index);
                            });
      
                            ScaffoldMessenger.of(
                              context,
                            ).clearSnackBars(); // Clean up existing snackbars
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${deletedItem.item} removed"),
                                action: SnackBarAction(
                                  label: "UNDO",
                                  onPressed: () {
                                    // 4. Re-insert the item if Undo is pressed
                                    setState(() {
                                      _manualList.insert(
                                        deletedIndex,
                                        deletedItem,
                                      );
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedScanIndex = isSelected ? null : index;
                              });
                            },
                            child: Container(
                              color: grocery.isSuggestion
                                  ? Colors.deepPurple.withOpacity(0.05)
                                  : (isSelected ? Colors.green.shade100 : Colors.transparent),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isSelected)
                                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
      
                                        Checkbox(
                                          value: grocery.isChecked,
                                          onChanged: (val) =>
                                              setState(() => grocery.isChecked = val!),
                                        ),
      
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            grocery.item,
                                            style: TextStyle(
                                                decoration: grocery.isChecked
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
      
      
                                        SizedBox(
                                          width: 50,
                                          child: TextFormField(
                                            initialValue: grocery.amount.toString(),
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                grocery.amount =
                                                    double.tryParse(val) ?? 1.0;
                                              });
                                            },
                                          ),
                                        ),
      
                                        DropdownButton<String>(
                                          value: _validUnits.contains(grocery.unit)
                                              ? grocery.unit
                                              : 'pcs',
                                          underline:
                                          Container(),
                                          isDense: true,
                                          items: _validUnits.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newUnit) {
                                            setState(() => grocery.unit = newUnit!);
                                          },
                                        ),
      
                                        DropdownButton<String>(
                                          value:
                                          _validCategories.contains(grocery.category)
                                              ? grocery.category
                                              : 'other',
                                          underline:
                                          Container(),
                                          isDense: true,
                                          items: _validCategories.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (category) {
                                            setState(() => grocery.category = category!);
                                          },
                                        ),
                                        PriceInput(
                                          item: grocery,
                                          onTotalChanged: () => setState(() {}),
                                        ),
                                      ],
                                    ),
                                    if (grocery.isSuggestion && grocery.aiReason != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 48.0, bottom: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.auto_awesome, size: 12, color: Colors.deepPurple),
                                            const SizedBox(width: 4),
                                            Text(
                                              grocery.aiReason!,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.deepPurple.shade700
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
                        ),
                      ],
                    );
                  },
                ),
                if (_manualList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "\$${_totalPrice.toStringAsFixed(2)}",
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start, // Keeps it to the left
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
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: addManualList,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (text) =>
                            addManualList(), // Fixed syntax: calls function correctly
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
                          fillColor: Colors.deepPurple.withOpacity(
                            0.05,
                          ), // Slight purple tint to distinguish from manual
                          labelText: 'Enter a dish or recipe',
                          hintText: 'e.g., Spaghetti Bolognese',
                          helperText:
                          'Tip: Add a recipe per request for best results',
                          helperStyle: const TextStyle(color: Colors.blueGrey),
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
                        onFieldSubmitted: (text) => generateWithAI(),
                      ),
                      const SizedBox(height: 12),
      
                      Container(
                        width: double.infinity,
                        height:
                        55, // Set a fixed height so the container doesn't jump/resize when switching to the loader
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.deepPurple.shade700,
                            ],
                          ),
                        ),
                        child: _isLoading
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
                          onPressed: () => generateWithAI(),
                          icon: const Icon(Icons.bolt, color: Colors.white),
                          label: const Text("Generate Grocery List"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            // Removed vertical padding here because height is now controlled by the Container
                          ),
                        ),
                      ),
                      const SizedBox(height: 15), // Spacing between sections
      
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
                              if (_selectedScanIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please tap an item on the list first!")),
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
                                setState(() {
                                  _manualList[_selectedScanIndex!].price = result;
      
                                  if (_selectedScanIndex! < _manualList.length - 1) {
                                    _selectedScanIndex = _selectedScanIndex! + 1;
                                  } else {
                                    _selectedScanIndex = null; // Unselect if at the end
                                  }
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.deepPurple.shade300),
                              color: Colors.white,
                            ),
                            child: isReStockLoading
                                ? const Center(child: CircularProgressIndicator())
                                : TextButton.icon(
                              onPressed: () => suggestRestockItems(),
                              icon: const Icon(Icons.psychology, color: Colors.deepPurple),
                              label: const Text("Smart Restock Suggestions"),
                            ),
                          )// Bottom padding for breathing room
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
