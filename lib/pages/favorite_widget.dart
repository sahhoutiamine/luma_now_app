import 'package:flutter/material.dart';
import 'package:movie/models/movie.dart';
import 'package:movie/database/favorite_save.dart';
import 'package:movie/pages/detail_widget.dart';

class MovieListScreenFavorite extends StatefulWidget {
  @override
  _MovieListScreenFavoriteState createState() => _MovieListScreenFavoriteState();
}

class _MovieListScreenFavoriteState extends State<MovieListScreenFavorite> {
  List<Movie> favorites = [];
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  void loadMovies() async {
    try {
      final result = await db.getFavorites();
      setState(() {
        favorites = result;
      });
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  void deleteMovie(Movie movie) async {
    await db.deleteFavorite(movie.id);
    loadMovies();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ تم حذف "${movie.title}" من المفضلة'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20202D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14142B),
        title: const Text(
          'الأفلام المفضلة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: favorites.isEmpty
          ? const Center(
        child: Text(
          'لا توجد أفلام مفضلة حتى الآن.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2 / 3,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final movie = favorites[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(movie: movie),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => deleteMovie(movie),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1A66D6).withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
