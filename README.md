# Zeotap Chatbot - Frontend (Flutter)

This is the **Flutter-based frontend** for the Zeotap Chatbot, which provides a user-friendly chat interface for querying and retrieving AI-generated responses. The backend is built using Flask.

## 🚀 Features
- Interactive chat UI
- API integration with the backend
- Displays AI-generated responses
- "Read More" link support for extended content

## 📷 Screenshots
![Chat UI](https://via.placeholder.com/600x300) <!-- Replace with actual screenshots -->

## 🛠️ Tech Stack
- **Flutter** (UI)
- **Dart** (Logic)
- **HTTP Package** (API Calls)
- **Firebase/Local Storage** (Optional for state management)

## 🏗️ Setup & Installation
### 1️⃣ Clone the Repository
git clone https://github.com/your-username/zeotap-chatbot-frontend.git
cd zeotap-chatbot-frontend

2️⃣ Install Dependencies

flutter pub get

3️⃣ Configure API Endpoint

Modify the _getBotResponse function in chat_app_screen.dart:

final uri = Uri.parse("http://127.0.0.1:5000/scrape"); // Replace with actual backend IP

4️⃣ Run the App

flutter run
