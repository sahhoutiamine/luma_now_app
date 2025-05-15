import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

const String baseUrl = 'https://api.themoviedb.org/3';
const String apiKey = '9623c7ad3f745d3320e43cc222dc8c7d';
class ApiService {
  static Future<List<Movie>> fetchPopularMovies() async {
    final url = '$baseUrl/movie/popular?api_key=$apiKey&language=ar';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (response.body == null || response.body.isEmpty) {
          throw Exception('Response body is empty');
        }
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('results')) {
          final List results = jsonData['results'];
          if (results != null && results.isNotEmpty) {
            return results.map((json) => Movie.fromJson(json)).toList();
          }
          else{
            return [];
          }
        } else {

          throw Exception('Invalid JSON structure: "results" key not found');
        }
      } else {
        throw Exception('Failed to load popular movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular movies: $e');
    }
  }

  static Future<List<Movie>> fetchTopRatedMovies() async {
    final url = '$baseUrl/movie/top_rated?api_key=$apiKey&language=ar';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (response.body == null || response.body.isEmpty) {
          throw Exception('Response body is empty');
        }
        final dynamic jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData.containsKey('results')) {
          final List results = jsonData['results'];
          if (results != null && results.isNotEmpty) {
            return results.map((json) => Movie.fromJson(json)).toList();
          }
          else{
            return [];
          }
        }
        else {
          throw Exception('Invalid JSON structure: "results" key not found');
        }
      } else {
        throw Exception('Failed to load top rated movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top rated movies: $e');
    }
  }

  static Future<List<Movie>> fetchUpcomingMovies() async {
    final url = '$baseUrl/movie/upcoming?api_key=$apiKey&language=ar';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (response.body == null || response.body.isEmpty) {
          throw Exception('Response body is empty');
        }
        final dynamic jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData.containsKey('results')) {
          final List results = jsonData['results'];
          if (results != null && results.isNotEmpty) {
            return results.map((json) => Movie.fromJson(json)).toList();
          }
          else{
            return [];
          }
        } else {
          throw Exception('Invalid JSON structure: "results" key not found');
        }
      } else {
        throw Exception('Failed to load upcoming movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching upcoming movies: $e');
    }
  }
}

