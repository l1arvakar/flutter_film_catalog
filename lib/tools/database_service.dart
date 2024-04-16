import 'package:flutter_film_catalog/models/film.dart';
import 'package:flutter_film_catalog/models/review.dart';
import 'package:flutter_film_catalog/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class DatabaseService {
  final String? uid;
  final Box _userBox = Hive.box('userBox');
  final Box _filmBox = Hive.box('filmBox');
  final Box _reviewsBox = Hive.box('reviewsBox');

  DatabaseService({required this.uid});

  final CollectionReference filmsCollection =
  FirebaseFirestore.instance.collection('film');

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  final CollectionReference reviewsCollection =
  FirebaseFirestore.instance.collection('reviews');

  Future createUserData() async {
    return await userCollection.doc(uid).set({
      'firstname': '',
      'lastname': '',
      'description': '',
      'birthday': DateTime.now(),
      'gender': 'Мужчина',
      'address': '',
      'phone': '',
      'filmCountry': 'US',
      'favDirector': '',
      'favActor': '',
      'favFilms': [],
    });
  }

  Future updateUserData(
      String firstname,
      String lastname,
      String description,
      DateTime birthday,
      String gender,
      String address,
      String phone,
      String filmCountry,
      String favDirector,
      String favActor) async {
    return await userCollection.doc(uid).update({
      'firstname': firstname,
      'lastname': lastname,
      'description' : description,
      'birthday': birthday,
      'gender': gender,
      'address': address,
      'phone': phone,
      'filmCountry': filmCountry,
      'favDirector': favDirector,
      'favActor': favActor
    });
  }

  Future updateUserFavFilms(List<String> favFilms) async {
    return await userCollection.doc(uid).update({
      'favFilms': favFilms,
    });
  }

  Future deleteUserData() async {
    return await userCollection.doc(uid).delete();
  }

  UserInfo _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserInfo(
        uid: uid!,
        firstname: snapshot['firstname'],
        lastname: snapshot['lastname'],
        description: snapshot['description'],
        birthday: DateTime.fromMicrosecondsSinceEpoch(
            (snapshot['birthday'] as Timestamp).microsecondsSinceEpoch),
        gender: snapshot['gender'],
        address: snapshot['address'],
        phone: snapshot['phone'],
        filmCountry: snapshot['filmCountry'],
        favDirector: snapshot['favDirector'],
        favActor: snapshot['favActor'],
        favFilms: (snapshot['favFilms'] as List).map((item) => item as String).toList());
  }

  Stream<UserInfo> get userData {
    // Попытка получить данные из кэша
    UserInfo? cachedUserData = _userBox.get(uid);
    if (cachedUserData != null) {
      return Stream.value(cachedUserData);
    }
    // Если данных нет в кэше, получаем их из Firestore и обновляем кэш
    return userCollection.doc(uid).snapshots().map((snapshot) {
      UserInfo userData = _userDataFromSnapshot(snapshot);
      _userBox.put(uid, userData);
      return userData;
    });
  }

  Future<String> getCurrentUserID() async {
    return uid ?? '';
  }


  Future<String> getUserFullName() async {
    // Попытка получить данные из кэша
    UserInfo? cachedUserData = _userBox.get(uid);
    if (cachedUserData != null) {
      return '${cachedUserData.firstname} ${cachedUserData.lastname}';
    }
    // Если данных нет в кэше, получаем их из Firestore
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    UserInfo userData = _userDataFromSnapshot(snapshot);
    // Обновляем кэш
    _userBox.put(uid, userData);
    return '${userData.firstname} ${userData.lastname}';
  }




  List<Film> filmListSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) {
      if (doc.data() == null) {
        return null;
      } else {
        return Film(
            uid: doc.id,
            name: doc['name'],
            year: doc['year'],
            description: doc['description'],
            country: doc['country'],
            genre: doc['genre'],
            director: doc['director'],
            averageRating: doc['averageRating'],
            reviews: (doc['reviews'] as List).map((item) => item as String).toList());
      }
    })
        .where((element) => element != null)
        .cast<Film>()
        .toList();
  }

  Stream<List<Film>> get films {
    // Попытка получить данные из кэша
    List<Film>? cachedFilms = _filmBox.get('films');
    if (cachedFilms != null) {
      return Stream.value(cachedFilms);
    }
    // Если данных нет в кэше, получаем их из Firestore и обновляем кэш
    return filmsCollection.snapshots().map((snapshot) {
      List<Film> films = filmListSnapshot(snapshot);
      _filmBox.put('films', films);
      return films;
    });
  }

  Future addReview(String filmID, String authorID, String text, int rating) async {
    DocumentReference reviewRef = await reviewsCollection.add({
      'authorID': authorID,
      'text': text,
      'rating': rating,
    });
    String reviewID = reviewRef.id;

    DocumentReference filmRef = filmsCollection.doc(filmID);
    await filmRef.update({
      'reviews': FieldValue.arrayUnion([reviewID])
    });

    return reviewID;
  }


  Future updateReview(String id, String text, int rating) async {
    return await reviewsCollection.doc(id).update({'text' : text, 'rating' : rating});
  }

  Stream<List<Review>> getReviewsForFilm(String filmUid) {
    List<Review>? cachedReviews = _reviewsBox.get('reviews');
    if (cachedReviews != null) {
      return Stream.value(cachedReviews);
    }
    return reviewsCollection.where('filmUid', isEqualTo: filmUid).snapshots().map((snapshot) {
      List<Review> reviews = reviewListSnapshot(snapshot);
      _reviewsBox.put('reviews', reviews);
      return reviews;
    });
  }


  List<Review> reviewListSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Review(
        uid: doc.id,
        authorID: doc['authorID'],
        text: doc['text'],
        rating: doc['rating'],
      );
    }).toList();
  }
}
