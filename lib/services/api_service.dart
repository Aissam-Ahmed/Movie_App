import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3/';
  static const String _token = 'YOUR_TOKEN_HERE'; 

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
