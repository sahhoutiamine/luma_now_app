import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'detail_widget.dart';
import 'category_movies_widget.dart';
import 'favorite_widget.dart';



class MovieListScreen extends StatefulWidget {


  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final Map<String, List<Movie>> _originalMovies = {};
  final Map<String, List<Movie>> _filteredMovies = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';
  Movie? _featuredMovie;

  @override
  void initState() {
    super.initState();
    _loadAllMovies();
  }

  Future<void> _loadAllMovies() async {
    try {
      final popular = await ApiService.fetchPopularMovies();
      final topRated = await ApiService.fetchTopRatedMovies();
      final upcoming = await ApiService.fetchUpcomingMovies();

      setState(() {
        _originalMovies['الأفلام الشائعة'] = popular;
        _originalMovies['الأعلى تقييماً'] = topRated;
        _originalMovies['القادمة'] = upcoming;

        _filteredMovies['الأفلام الشائعة'] = List.from(popular);
        _filteredMovies['الأعلى تقييماً'] = List.from(topRated);
        _filteredMovies['القادمة'] = List.from(upcoming);


        if (popular.isNotEmpty) {
          _featuredMovie = popular[DateTime.now().millisecondsSinceEpoch % popular.length];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  void _filterMovies(String query) {
    setState(() {
      if (query.isEmpty) {
        _originalMovies.forEach((category, movies) {
          _filteredMovies[category] = List<Movie>.from(movies);
        });
      } else {
        _filteredMovies.forEach((category, _) {
          final originalList = _originalMovies[category] ?? [];
          _filteredMovies[category] = originalList
              .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    });
  }

  Widget _buildFeaturedMovieBanner() {
    if (_featuredMovie == null) return SizedBox();

    final imageUrl = _featuredMovie!.backdropPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w1280${_featuredMovie!.backdropPath}'
        : 'https://via.placeholder.com/800x400?text=No+Image';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(movie: _featuredMovie!),
          ),
        );
      },
      child: Container(
        height: 400,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade900,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade800,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white70, size: 50),
                      SizedBox(height: 8),
                      Text("لا توجد صورة", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            // تأثير التضبيب
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 30,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _featuredMovie!.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 5),
                      Text(
                        _featuredMovie!.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<Movie> movies) {
    final double imageHeight = 225;
    final double imageWidth = 150;
    final double interItemSpacing = 10.0;

    if (movies.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Text(
            'لا توجد أفلام تطابق بحثك في هذه الفئة.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: imageHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          final imageUrl = movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w342${movie.posterPath}'
              : 'https://via.placeholder.com/150x225?text=No+Image';

          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: (index == movies.length - 1) ? 0 : interItemSpacing,
            ),
            child: GestureDetector(
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
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: imageWidth,
                      height: imageHeight,
                      color: Colors.grey.shade800,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              color: Colors.white70, size: 40),
                          SizedBox(height: 4),
                          Text("لا توجد صورة",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
            : _errorMessage.isNotEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(_errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF14142B),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎬 استكشف الأفلام',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.deepPurpleAccent,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: _filterMovies,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن فيلم...',
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2A2A55),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 18),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              _buildFeaturedMovieBanner(),
              ..._filteredMovies.entries.map((entry) {
                final categoryName = entry.key;
                final moviesInHorizontalList = entry.value;
                final allMoviesForCategory = _originalMovies[categoryName] ?? [];

                if (_searchController.text.isNotEmpty && moviesInHorizontalList.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (allMoviesForCategory.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryMoviesPage(
                                        categoryTitle: categoryName,
                                        movies: allMoviesForCategory,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(50,30),
                                  alignment: AlignmentDirectional.centerEnd,
                                ),
                                child: const Text(
                                  'المزيد',
                                  style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHorizontalMovieList(moviesInHorizontalList),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF242149),
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MovieListScreenFavorite()),
            );
          },
          child: const Icon(Icons.favorite, color: Colors.redAccent),
          tooltip: 'الأفلام المفضلة',
        ),
      ),
    );
  }
}

