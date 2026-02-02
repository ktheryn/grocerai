# 🛒 GrocerAI

The Intelligent Grocery Companion

GrocerAI is a high-performance Flutter application that leverages Artificial Intelligence to transform how you plan, shop, and manage your kitchen. No more manual typing or forgotten ingredients; let AI handle the logistics.

✨ Key Features

🥗 AI Recipe-to-List Engine
Paste a recipe name or a URL, and GrocerAI's NLP engine extracts the necessary ingredients, automatically adjusting quantities and categories for your shopping trip.

🧠 Predictive Smart Suggestions
Our "Historical Insight" algorithm analyzes your shopping patterns:
Frequency Tracking: Identifies your "Must-Haves."
Time-Since-Purchase: Predicts when you're running low (e.g., "You bought milk 3 days ago; you're likely out!").

📸 Instant Price Scanner
Use your camera to scan items in-store. GrocerAI instantly pulls pricing data and fills your list details, helping you track your budget in real-time.

♻️ Persistent Lists & Templates
Save your "Weekly Essentials" or "Holiday Feast" lists. Reuse, edit, and sync them across devices so you never have to start from scratch.

🚀 Technical Architecture
This application was built to demonstrate proficiency in modern mobile engineering standards:

Frontend: Flutter (Dart)
Backend as a Service: Firebase (Auth, Firestore for sync).
AI Models: Gemini API 
OCR: Google ML Kit (for price and label scanning

## 📱 Visual Walkthrough & User Flow

| **Secure Authentication** | **AI Command Center** | **Smart Suggestions** |
| --- | --- | --- |
| <img src="https://github.com/user-attachments/assets/1654e537-7dde-4bad-a691-0fe2ec5d049e" width="250"> | <img src="https://github.com/user-attachments/assets/58218235-2506-4fc5-80a7-af512dfe68c8" width="250"> | <img src="https://github.com/user-attachments/assets/ef7dcb3d-16e8-4acf-9250-92f95eac240b" width="250"> |
| **Secure Entry:** Custom branded login screen using Firebase Authentication for secure user session management. | **The "Blank Slate":** The central hub. Users can quick-add items or invoke the **GenAI Engine** to generate lists from abstract recipe requests. | **Predictive Logic:** The list populates with "Staple" tags. Note the purple text indicating AI-driven insights on stock levels. |

| **Categorization & Budgeting** | **OCR and Image to Caption** | **History & Analytics** |
| --- | --- | --- |
| <img src="https://github.com/user-attachments/assets/5ff21113-c2d9-4800-9e79-754f5b068eed" width="250"> | <img src="https://github.com/user-attachments/assets/7a701216-76d4-4916-b8a1-29a33962d37d" width="250"> | <img src="https://github.com/user-attachments/assets/79c9fc72-a5cc-4d12-9df9-d5b4296fc76c" width="250"> |
| **Structured Data:** Items are auto-sorted by aisle/category. Budgeting features track estimated costs in real-time. | **Image to Caption:** Using the device camera to capture price and using Google ML kit and Gemini API to instantly fills pricing details. | **Data Persistence:** Detailed history allows users to "Reuse" previous lists, turning historical data into future efficiency. |

| **Shopping History** || **Deletion & Cleanup** |
| --- | --- | --- |
| <img src="https://github.com/user-attachments/assets/5d49574c-29af-4e3f-8fb7-eb10e4b8e27a" width="200"> <img src="https://github.com/user-attachments/assets/fd20be50-1d2a-4771-b801-28c8af0b746e" width="200"> | | <img src="https://github.com/user-attachments/assets/5d8b3722-1336-42d9-b910-00fd29b31981" width="250"> |
| **Session Tracking:** A clean list view of all past shopping trips with date stamps and total spend summaries. || **Intuitive UX:**Clear all functionality for easy clean list and swipe to delete functionality for each grocery and history|






