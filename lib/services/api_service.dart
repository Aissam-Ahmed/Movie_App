import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3/';
  static const String _token = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5NDJiOWM0OTViYTgxMzg0NDMzZTdlMDE4NTk0ZDAxYyIsIm5iZiI6MTc1MjI0MTk5MS43NjEsInN1YiI6IjY4NzExNzQ3NTUwNGY2Y2Q5MGVkNzVkMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.7olUkxaBl_RuB_Z26iBIxuvlpLj3a-mZa47cAxuObfc'; // استبدله

  static Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}movie/popular?language=en-US&page=1'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json;charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Movie> movies = List<Movie>.from(
        data['results'].map((m) => Movie.fromJson(m)),
      );
      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}search/movie?query=$query&language=en-US&page=1'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json;charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Movie> movies = List<Movie>.from(
        data['results'].map((m) => Movie.fromJson(m)),
      );
      return movies;
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
