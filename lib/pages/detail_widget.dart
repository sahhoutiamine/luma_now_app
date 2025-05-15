import 'package:flutter/material.dart';
import '../database/favorite_save.dart';
import '../models/movie.dart';

class DetailPage extends StatefulWidget {
  final Movie movie;
  const DetailPage({super.key, required this.movie});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final db = DatabaseHelper();
  bool isFavorite = false;
  bool _isToggleInProgress = false;

  @override
  void initState() {
    super.initState();

    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    print("DetailPage: يتم التحقق مما إذا كان الفيلم ${widget.movie.id} في المفضلة.");
    try {

      final List<Movie> favorites = await db.getFavorites();


      if (!mounted) return;

      final bool exists = favorites.any((favMovie) => favMovie.id == widget.movie.id);
      print("DetailPage: حالة الفيلم ${widget.movie.id} في المفضلة: $exists");

      if (mounted) {
        setState(() {
          isFavorite = exists;
        });
      }
    } catch (e) {
      print("DetailPage: خطأ في checkIfFavorite للفيلم ${widget.movie.id}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في التحقق من المفضلة: ${e.toString().substring(0, (e.toString().length > 60) ? 60 : e.toString().length)}..."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> toggleFavorite() async {

    if (_isToggleInProgress) {
      print("DetailPage: عملية التبديل جارية بالفعل للفيلم ${widget.movie.id}.");
      return;
    }


    if (!mounted) return;


    setState(() {
      _isToggleInProgress = true;
    });

    print("DetailPage: يتم تبديل حالة المفضلة للفيلم ${widget.movie.id}. الحالة الحالية: $isFavorite");


    bool newFavoriteStatus = !isFavorite;

    try {
      if (newFavoriteStatus == true) {
        print("DetailPage: محاولة إضافة الفيلم ${widget.movie.id} إلى المفضلة.");
        await db.insertFavorite(widget.movie);
        print("DetailPage: تم إضافة الفيلم ${widget.movie.id} بنجاح إلى المفضلة (قاعدة البيانات).");

        if (mounted) {
          setState(() {
            isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تمت إضافة الفيلم إلى المفضلة"),
              backgroundColor: Color(0xFF1A66D6),
            ),
          );
        }
      } else {
        print("DetailPage: محاولة إزالة الفيلم ${widget.movie.id} من المفضلة.");
        await db.deleteFavorite(widget.movie.id);
        print("DetailPage: تم إزالة الفيلم ${widget.movie.id} بنجاح من المفضلة (قاعدة البيانات).");

        if (mounted) {
          setState(() {
            isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تمت إزالة الفيلم من المفضلة"),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      print("DetailPage: خطأ أثناء تبديل حالة المفضلة للفيلم ${widget.movie.id}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("لم يتم تحديث المفضلة: ${e.toString().substring(0, (e.toString().length > 60) ? 60 : e.toString().length)}..."),
            backgroundColor: Colors.red,
          ),
        );

        await checkIfFavorite();
      }
    } finally {

      if (mounted) {
        setState(() {
          _isToggleInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF20202D),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 500,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Image.network(
                          'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                          width: double.infinity,
                          height: 500,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.4),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade800, child: Center(child: Icon(Icons.error_outline, color: Colors.white70, size: 48))),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 250,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF20202D),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon:
                      const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      onPressed: _isToggleInProgress ? null : toggleFavorite,
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                            width: 160,
                            height: 240,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(width: 160, height: 240, color: Colors.grey.shade800, child: Center(child: Icon(Icons.error_outline, color: Colors.white70, size: 48))),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoCard(
                      icon: Icons.calendar_today,
                      label: "تاريخ الإصدار",
                      value: movie.releaseDate.isNotEmpty
                          ? movie.releaseDate
                          : "غير متوفر",
                    ),
                    _InfoCard(
                      icon: Icons.language,
                      label: "اللغة الأصلية",
                      value: movie.originalLanguage.toUpperCase(),
                    ),
                    _InfoCard(
                      icon: Icons.star,
                      label: "التقييم",
                      value: "${movie.voteAverage} / 10",
                    ),
                    _InfoCard(
                      icon: Icons.how_to_vote,
                      label: "عدد الأصوات",
                      value: movie.voteCount.toString(),
                    ),
                    _InfoCard(
                      icon: Icons.whatshot,
                      label: "الشعبية",
                      value: movie.popularity.toStringAsFixed(1),
                    ),
                    _InfoCard(
                      icon: Icons.theater_comedy,
                      label: "للكبار فقط؟",
                      value: movie.adult ? "نعم" : "لا",
                    ),
                    _InfoCard(
                      icon: Icons.movie,
                      label: "العنوان الأصلي",
                      value: movie.originalTitle,
                    ),
                    _InfoCard(
                      icon: Icons.category,
                      label: "تصنيفات النوع",
                      value: movie.genreIds.isNotEmpty
                          ? movie.genreIds.join("، ")
                          : "غير متوفر",
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الوصف",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.overview.isNotEmpty
                          ? movie.overview
                          : 'لا يوجد وصف متاح لهذا الفيلم.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3B),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}