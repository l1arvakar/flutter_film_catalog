import 'package:flutter_film_catalog/models/film.dart';
import 'package:flutter_film_catalog/models/user.dart';
import 'package:flutter_film_catalog/screens/film_preview.dart';
import 'package:flutter_film_catalog/tools/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilmsList extends StatefulWidget {
  const FilmsList({super.key, required this.onlyFavourites, required this.search});

  final bool onlyFavourites;
  final String search;

  @override
  State<FilmsList> createState() => _FilmsListState();
}

class _FilmsListState extends State<FilmsList> {
  @override
  Widget build(BuildContext context) {
    final bool onlyFavourites = widget.onlyFavourites;
    final String search = widget.search;

    final user = Provider.of<User?>(context);
    final films = Provider.of<List<Film>>(context);

    return StreamBuilder<UserInfo>(
        stream: DatabaseService(uid: user?.uid).userData,
        builder: (context, snapshot) {
          UserInfo? userData;
          if (snapshot.hasData) {
            userData = snapshot.data!;
            for (Film film in films) {
              if (userData!.favFilms.any((element) => element == film.uid)) {
                film.isFav = true;
              } else {
                film.isFav = false;
              }
            }
          }

          if(onlyFavourites){
            films.removeWhere((film) => !film.isFav);
          }

          List<Film> filteredByGenresFilms = films.where((film) {
            List<String> genres = film.genre.split(',').map((genre) => genre.trim()).toList();
            return genres.any((genre) => genre.toLowerCase() == (search.toLowerCase()));
          }).toList();

          List<Film> filteredByNameFilms = search.isEmpty ? films : films.where((film) => film.name.toLowerCase().contains(search.toLowerCase())).toList();

          List<Film> filteredFilms = filteredByNameFilms.toSet().union(filteredByGenresFilms.toSet()).toList();

          return ListView.builder(
              itemCount: filteredFilms.length,
              itemBuilder: (context, index) {
                return FilmPreview(film: filteredFilms[index], userData: userData);
              });
        });
  }
}

