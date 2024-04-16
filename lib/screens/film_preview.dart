import 'package:flutter_film_catalog/models/film.dart';
import 'package:flutter_film_catalog/models/user.dart';
import 'package:flutter_film_catalog/screens/film_info.dart';
import 'package:flutter_film_catalog/screens/preview.dart';
import 'package:flutter_film_catalog/tools/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tools/constants.dart';

class FilmPreview extends StatelessWidget {
  const FilmPreview({super.key, required this.film, required this.userData});

  final UserInfo? userData;
  final Film film;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    void showFilmPreview() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
              child: FilmInfo(film: film, folderPath: '${film.name}/screenshots',),
            );
          });
    }

    return Center(

      child: Container(
        height: 320,
        width: 300,
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0), // Adding padding to top of the poster
                    child: PreviewImage(
                      path: '${film.name}/Poster.jpg',
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  showFilmPreview();
                },
                contentPadding: EdgeInsets.all(10.0),
                title: Text(
                  film.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: Text(
                  film.year,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    film.isFav ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () {
                    if (userData != null) {
                      if (film.isFav) {
                        userData!.favFilms.remove(film.uid);
                      } else {
                        userData!.favFilms.add(film.uid);
                      }
                      DatabaseService(uid: user!.uid)
                          .updateUserFavFilms(userData!.favFilms);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
