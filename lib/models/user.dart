class User {
  final String uid;

  User({required this.uid});
}

class UserInfo {
  final String uid;
  final String firstname;
  final String lastname;
  final String description;
  final DateTime birthday;
  final String gender;
  final String address;
  final String phone;
  final String filmCountry;
  final String favDirector;
  final String favActor;
  final List<String> favFilms;

  UserInfo({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.birthday,
    required this.gender,
    required this.address,
    required this.phone,
    required this.filmCountry,
    required this.favDirector,
    required this.favActor,
    required this.description,
    required this.favFilms,
  });
}
