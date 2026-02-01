import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/locator.dart';
import 'package:uuid/uuid.dart';

class AIGeneratedGroceryRepository {
  final GenerativeModel _model = getIt<GenerativeModel>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String _buildFromRecipePrompt(String recipe) {
    return """
      Generate a grocery list for a recipe: $recipe. 
      Return the result as a JSON array of objects with the following keys:
      "item" (string), "amount" (number), "unit" (string), "category" (string).
      Rules:
      - "amount" MUST be a number.
      - "unit" must be one of: kg, g, pcs, packs, ml, L, can, box, bottle.
      - Categories: Produce, Dairy & Eggs, Bakery, Meat & Poultry, Seafood, Pantry, Frozen Foods, Beverages, Household, Other.
      - If a quantity is vague, default "amount" to 1.0.
      - Do not include any additional text or explanations.
      - Do not include spices or condiments that are not considered as main ingredient of the recipe. 
      - Maximum of 10 items.
    """;
  }

  String _buildFromStockHistorySuggestion(String historyContext) {
    return """
  You are a Grocery Logic Agent. Analyze the purchase history provided below.
  
  Current Date: February 20, 2026

  ### DATA INTERPRETATION:
  - IMPORTANT: Every item has its own 'lastPurchased' value. Do not assume all items share the same date.
  - Calculate the gap individually: (Feb 20, 2026) minus (item['lastPurchased']).
  - If the gap is identical for many items, ensure they actually have the same 'lastPurchased' date in the source data.

  ### SELECTION LOGIC (PRIORITY ORDER):
  1. HIGH-FREQUENCY STAPLES: Items bought 3+ times. Suggest ONLY if (Current Date - Last Purchase Date) > Average Gap.
  2. OVERDUE STAPLES: Items bought 2 times but missing for 10+ days beyond their usual interval.
  3. RECENT ONE-OFFS: For items bought ONLY ONCE, only suggest if they were purchased within the last 30 days AND are exactly 14-21 days overdue. 
  4. DISCARD: Do not suggest items bought only once if they are more than 30 days overdue (assume they were a one-time purchase).
  5. Give maximum of 5 suggestions only

  ### STRICT FORMATTING RULES:
  1. CATEGORIES: ONLY "Produce", "Dairy", "Bakery", "Meat", "Seafood", "Pantry", or "Other".
  2. UNITS: ONLY "kg", "g", or "pcs".
  3. AMOUNT: Must be a double/number (e.g., 1.0).
  4. AI REASON: Max 5 words. **Be specific with numbers**.
     - GOOD: "Staple, 5 days overdue"
     - GOOD: "Bought 4x; due now"
     - BAD: "You buy this a lot" (Too vague)

  ### HISTORY TO ANALYZE:
  $historyContext

  ### OUTPUT FORMAT:
  Return ONLY a JSON array. No conversational text.
  [
    {
      "item": "Bread",
      "category": "Bakery",
      "amount": 1.0,
      "unit": "pcs",
      "aiReason": "Staple, 3 days overdue"
    }
  ]
""";
  }

  String _buildPricePriompt(String ocrText) {
    return """
          You are given raw OCR text extracted from a product price tag.
          
          Task:
          - Extract the FINAL product price ONLY.
          - Ignore quantities, weights (g, kg, ml), barcodes, dates, discounts, and store codes.
          - Prefer values that look like a price
          - If multiple prices exist, return the MOST LIKELY final price.
          
          Return format (STRICT):
          {
            "price": number
          }
          
          Rules:
          - "price" MUST be a number (not a string).
          - Do NOT include currency symbols.
          - Do NOT include any additional text.
          - If no valid price is found, return:
            { "price": null }
          
          OCR TEXT:
          ${ocrText}
          """;
  }

  Future<List<GroceryItem>> fetchAIGroceryList(String recipeName) async {
    final prompt = _buildFromRecipePrompt(recipeName);
    return _generateAndParse(prompt, isAiGenerated: true);
  }

  Future<List<GroceryItem>> getSmartRestockSuggestions(String historyContext) async {
    final prompt = _buildFromStockHistorySuggestion(historyContext);
    return _generateAndParse(prompt, isSuggestion: true);
  }

  Future<double> fetchPriceFromOcrText(String ocrText) async {
    final prompt = _buildPricePriompt(ocrText);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) return 0.0;
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      final price = (data['price'] as num?)?.toDouble();
      return price ?? 0.0;
    } catch (e) {
      throw Exception("AI Price Extraction failed: $e");
    }
  }

  Future<List<GroceryItem>> _generateAndParse(
      String prompt, {
        bool isAiGenerated = false,
        bool isSuggestion = false,
      }) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) return [];
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> data = jsonDecode(cleanJson);

      return data.map((json) {
        return GroceryItem.fromJson(json).copyWith(
          id: _uuid.v4(),
          isAiGenerated: isAiGenerated,
          isSuggestion: isSuggestion,
        );
      }).toList();
    } catch (e) {
      throw Exception("AI Generation failed: $e");
    }
  }

  Future<String> getHistoryContext() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final historySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('grocery_history')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return historySnapshot.docs.map((doc) {
      final items = (doc['items'] as List)
          .map((i) => i['item'] ?? '')
          .join(', ');
      return "Date: ${doc['timestamp'].toDate()}, Items: $items";
    }).join("\n");
  }
}
