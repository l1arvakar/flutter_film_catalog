class Film {
  final String uid;
  final String name;
  final String year;
  final String description;
  final String country;
  final String genre;
  final String director;
  final double averageRating;
  final List<String> reviews;

  bool isFav = false;

  Film({
    required this.uid,
    required this.name,
    required this.year,
    required this.description,
    required this.country,
    required this.genre,
    required this.director,
    required this.averageRating,
    required this.reviews,
  });
}
