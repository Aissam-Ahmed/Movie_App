import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/movie.dart';
import 'services/api_service.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Movie App',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> futureMovies;
  List<int> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService.fetchPopularMovies();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoriteIds = favs.map((e) => int.parse(e)).toList();
    });
  }

  Future<void> toggleFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteIds.contains(movieId)) {
        favoriteIds.remove(movieId);
      } else {
        favoriteIds.add(movieId);
      }
    });
    prefs.setStringList(
      'favorites',
      favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  void openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          favoriteIds: favoriteIds,
          toggleFavorite: toggleFavorite,
        ),
      ),
    );
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(favoriteIds: favoriteIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: openSearch,
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: openFavorites,
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final movies = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final isFavorite = favoriteIds.contains(movie.id);
                return MovieCard(
                  movie: movie,
                  isFavorite: isFavorite,
                  toggleFavorite: toggleFavorite,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات.\nيرجى المحاولة لاحقًا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureMovies = ApiService.fetchPopularMovies();
                      });
                    },
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFavorite;
  final Function(int) toggleFavorite;

  MovieCard({
    required this.movie,
    required this.isFavorite,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: movie.posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Release: ${movie.releaseDate}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: () => toggleFavorite(movie.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<int> favoriteIds;

  FavoritesScreen({required this.favoriteIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: FutureBuilder<List<Movie>>(
        future: ApiService.fetchPopularMovies(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final movies = snapshot.data!
                .where((m) => favoriteIds.contains(m.id))
                .toList();

            if (movies.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد أفلام مفضلة حالياً.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return MovieCard(
                  movie: movie,
                  isFavorite: true,
                  toggleFavorite: (_) {},
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل المفضلات.\nيرجى المحاولة لاحقًا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // إعادة تحميل الشاشة بإعادة البناء
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FavoritesScreen(favoriteIds: favoriteIds),
                        ),
                      );
                    },
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final List<int> favoriteIds;
  final Function(int) toggleFavorite;

  SearchScreen({required this.favoriteIds, required this.toggleFavorite});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<Movie> searchResults = [];
  bool isLoading = false;
  String? errorMessage;

  void search() async {
    if (query.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await ApiService.searchMovies(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء البحث. حاول مرة أخرى.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: search,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else if (searchResults.isEmpty && query.isNotEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على نتائج.\nجرّب كلمة أخرى.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final movie = searchResults[index];
          final isFavorite = widget.favoriteIds.contains(movie.id);
          return MovieCard(
            movie: movie,
            isFavorite: isFavorite,
            toggleFavorite: widget.toggleFavorite,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بحث عن أفلام'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'اكتب هنا للبحث...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => query = val,
              onSubmitted: (_) => search(),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
