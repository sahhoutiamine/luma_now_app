import 'package:flutter/material.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final String backdropPath;
  final String originalLanguage;
  final List<int> genreIds;
  final bool adult;
  final String originalTitle;
  final String mediaType;
  final int voteCount;
  final bool video;
  final double popularity;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.backdropPath,
    required this.originalLanguage,
    required this.genreIds,
    required this.adult,
    required this.originalTitle,
    required this.mediaType,
    required this.voteCount,
    required this.video,
    required this.popularity,
  });

  /// ✅ تحويل إلى Map لتخزين في SQLite
  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'backdropPath': backdropPath,
      'originalLanguage': originalLanguage,
      'genreIds': genreIds.join(','), // نحفظها كسلسلة نصية
      'adult': adult ? 1 : 0,
      'originalTitle': originalTitle,
      'mediaType': mediaType,
      'voteCount': voteCount,
      'video': video ? 1 : 0,
      'popularity': popularity,
    };
    print('Movie toMap: $map');
    return map;
  }

  /// ✅ التحويل من SQLite
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      overview: map['overview'],
      voteAverage: map['voteAverage'],
      releaseDate: map['releaseDate'],
      backdropPath: map['backdropPath'],
      originalLanguage: map['originalLanguage'],
      genreIds: (map['genreIds'] as String)
          .split(',')
          .map((e) => int.tryParse(e) ?? 0)
          .toList(),
      adult: map['adult'] == 1,
      originalTitle: map['originalTitle'],
      mediaType: map['mediaType'],
      voteCount: map['voteCount'],
      video: map['video'] == 1,
      popularity: map['popularity'],
    );
  }

  /// ✅ التحويل من JSON الخاص بـ TMDB API
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      adult: json['adult'] ?? false,
      originalTitle: json['original_title'] ?? '',
      mediaType: json['media_type'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      video: json['video'] ?? false,
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }
}