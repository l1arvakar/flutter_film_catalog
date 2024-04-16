import 'package:flutter_film_catalog/models/film.dart';
import 'package:flutter_film_catalog/screens/films_list.dart';
import 'package:flutter_film_catalog/screens/fav_films.dart';
import 'package:flutter_film_catalog/screens/settings.dart';
import 'package:flutter_film_catalog/tools/wrapper.dart';
import 'package:flutter_film_catalog/tools/authentication_service.dart';
import 'package:flutter_film_catalog/tools/database_service.dart';
import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  final AuthenticationService _auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Film>>.value(
      value: DatabaseService(uid: null).films,
      initialData: [],
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: SvgPicture.asset('assets/site_logo.svg'),
            title: Text('Все фильмы'),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
            automaticallyImplyLeading: false,
            backgroundColor: primaryColor,
            actionsIconTheme: IconThemeData(),
            elevation: 0.0,
            actions: <Widget>[
              PopupMenuButton<MenuItem>(
                color: primaryColor,
                iconColor: secondaryColor,
                onSelected: (MenuItem item) {
                  switch (item) {
                    case MenuItem.Home:
                    // TODO: Handle this case.
                      break;
                    case MenuItem.Logout:
                      _auth.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Wrapper()));
                      break;
                    case MenuItem.Settings:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Settings()));
                      break;
                    case MenuItem.Favourites:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavFilms()));
                      break;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu, color: secondaryColor),
                    SizedBox(width: 10),
                    Text('Меню', style: TextStyle(color: secondaryColor)),
                    SizedBox(width: 20)
                  ],
                ),
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<MenuItem>>[
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.Favourites,
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: secondaryColor),
                        Text('Избранное',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.Settings,
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: secondaryColor),
                        Text('Профиль',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.Logout,
                    child: Row(
                      children: [
                        Icon(Icons.door_front_door_outlined,
                            color: secondaryColor),
                        Text('Выйти',
                            style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: backgroundColor,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию фильма',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    setState(() {

                    });
                  },

                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: backgroundColor),
                  child: FilmsList(onlyFavourites: false, search: _searchController.text),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

