import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'detail_widget.dart';

class CategoryMoviesPage extends StatelessWidget {
  final String categoryTitle;
  final List<Movie> movies;

  const CategoryMoviesPage({
    Key? key,
    required this.categoryTitle,
    required this.movies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryTitle, style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF14142B),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF20202D),
        body: movies.isEmpty
            ? Center(
          child: Text(
            'لا توجد أفلام في هذه الفئة.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 2 / 3,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final imageUrl = movie.posterPath.isNotEmpty
                ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' // استخدام دقة مناسبة للشبكة
                : 'https://via.placeholder.com/300x450?text=No+Image&fontsize=16';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(movie: movie),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade800,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white70, size: 40),
                        SizedBox(height: 4),
                        Text("لا توجد صورة", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}