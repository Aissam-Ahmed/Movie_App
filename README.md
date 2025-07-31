# 🎬 Flutter Movie App

A simple Flutter app that integrates with the TMDB API to display popular movies, search for movies, and let users save favorites locally.

## 📱 Features
- ✅ Fetch and display trending/popular movies.  
- ✅ Search movies by title.  
- ✅ Add/remove movies to/from local favorites.  
- ✅ Favorites persist using `SharedPreferences`.  
- ✅ Beautiful card UI with large movie posters.  
- ✅ User-friendly error handling with retry options.

## ⚙️ Technologies
- **Flutter** & **Dart**  
- **TMDB API v3**  
- **http** package for REST API calls  
- **SharedPreferences** for local storage  

## 🚀 Getting Started
1. Install dependencies:  
   ```bash
   flutter pub get
   
Add your TMDB API token:
Open lib/services/api_service.dart and replace the placeholder:
static const String _token = 'YOUR_TOKEN_HERE';

Run the app:
   flutter run

🧩 Project Structure
Copy
lib/
 ├── main.dart               # Main app & screens (Movies, Favorites, Search)
 ├── models/
 │   └── movie.dart          # Movie data model
 └── services/
     └── api_service.dart    # TMDB API integration with your token
