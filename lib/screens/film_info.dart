import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_film_catalog/models/film.dart';
import 'package:flutter_film_catalog/screens/review_edit.dart';
import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/review.dart';
import '../models/user.dart';
import '../tools/database_service.dart';

class FilmInfo extends StatelessWidget {
  const FilmInfo({super.key, required this.film, required this.folderPath});

  final String folderPath;
  final Film film;

  Future<List<String>> _getDetailedFilesUrl(String firebasePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      try {
        List<String>? cachedUrls = prefs.getStringList(firebasePath);
        if (cachedUrls != null && cachedUrls.isNotEmpty) {
          return cachedUrls;
        }
      } catch (e) {
        print('Error reading cached URLs from SharedPreferences: $e');
      }
      return [];
    }

    try {
      List<String> result = [];
      final files = await FirebaseStorage.instance.ref(firebasePath).listAll();
      for (var file in files.items) {
        String url = await file.getDownloadURL();
        result.add(url);
      }
      await prefs.setStringList(firebasePath, result);
      return result;
    } catch (e) {
      print('Error getting download URLs from Firebase Storage: $e');
      try {
        List<String>? cachedUrls = prefs.getStringList(firebasePath);
        if (cachedUrls != null && cachedUrls.isNotEmpty) {
          return cachedUrls;
        }
      } catch (e) {
        print('Error reading cached URLs from SharedPreferences: $e');
      }
      return [];
    }
  }

  Future<List<Review>> _getReviews() async {
    // Получаем отзывы для списка uid из объекта Film
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('reviews').where(FieldPath.documentId, whereIn: film.reviews).get();

    // Проходим по каждому документу в результате запроса и создаем объекты Review
    return querySnapshot.docs.map((doc) {
      return Review(
        uid: doc.id,
        authorID: doc['authorID'],
        text: doc['text'],
        rating: doc['rating'],
      );
    }).toList();
  }

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;

    double totalRating = 0;
    for (var review in reviews) {
      totalRating += review.rating;
    }
    return totalRating / reviews.length;
  }

  Widget _loading() {
    return const SizedBox(
      height: 150,
      width: 150,
      child: SpinKitChasingDots(
        color: primaryColor,
        size: 20.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String genre = film.genre.replaceAll('/', '\n');
    final user = Provider.of<User?>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(film.name, style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold)),
          Text(film.year, style: TextStyle(fontSize: 17, color: textColor)),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 150,
            child: FutureBuilder(
              future: _getDetailedFilesUrl(folderPath),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return CarouselSlider(
                      options: CarouselOptions(height: 150.0),
                      items: snapshot.data!.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: SizedBox(
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    height: 150,
                                    placeholder: (context, url) => _loading(),
                                    errorWidget: (context, url, error) => SvgPicture.asset('assets/site_logo.svg', height: 150),
                                  ),
                                ));
                          },
                        );
                      }).toList(),
                    );
                  } else if (snapshot.error != null || snapshot.data!.isEmpty) {
                    return SvgPicture.asset('assets/site_logo.svg', height: 150);
                  }
                }
                return _loading();
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text('Описание', style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold)),
          Text(film.description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 17, color: textColor)),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Страна', style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.bold)),
              Image.asset(
                'packages/country_code_picker/flags/${film.country.toLowerCase()}.png',
                height: 50,
                alignment: Alignment.centerRight,
              )
              // Text(car.country, style: TextStyle(fontSize: 17, color: textColor)),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Жанр', style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.bold)),
              Text(genre, textAlign: TextAlign.right, style: TextStyle(fontSize: 17, color: textColor)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Режиссёр', style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.bold)),
              Text(film.director, style: TextStyle(fontSize: 17, color: textColor)),
            ],
          ),
          SizedBox(height: 10),
          FutureBuilder(
            future: _getReviews(),
            builder: (context, AsyncSnapshot<List<Review>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              } else if (snapshot.hasError) {
                return Text('Рецензий на этот фильм пока нет');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<Review> reviews = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Средняя оценка: ${_calculateAverageRating(reviews).toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              } else {
                return Text('Рецензий на этот фильм пока нет'); // Если нет отзывов, ничего не отображаем
              }
            },
          ),
          FutureBuilder(
            future: _getReviews(),
            builder: (context, AsyncSnapshot<List<Review>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рецензии:',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Review review = snapshot.data![index];
                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(review.authorID)
                              .get(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return _loading();
                            } else if (userSnapshot.hasError) {
                              return Text('Ошибка загрузки данных пользователя');
                            } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              String authorFirstName = userSnapshot.data!.get('firstname');
                              String authorLastName = userSnapshot.data!.get('lastname');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$authorFirstName $authorLastName:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(review.text),
                                  Divider(),
                                ],
                              );
                            } else {
                              return Text('Рецензий на этот фильм пока нет'); // Если данных о пользователе нет, ничего не отображаем
                            }
                          },
                        );
                      },
                    ),
                  ],
                );
              } else {
                return SizedBox(); // Если нет отзывов, ничего не отображаем
              }
            },
          ),
          FutureBuilder(
            future: _getReviews(),
            builder: (context, AsyncSnapshot<List<Review>> snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () {
                        Review? userReview;
                        if (snapshot.hasData && snapshot.data!.any((review) => review.authorID == user!.uid)) {
                            userReview = snapshot.data!.firstWhere((review) => review.authorID == user!.uid);
                        } else {
                            userReview = null;
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewEditDialog(filmID: film.uid, userID: user!.uid, existingReview: userReview)));
                      },
                      child: Text('Моя рецензия', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
            },
          ),

        ],
      ),
    );
  }
}
