import 'package:flutter_film_catalog/models/user.dart';
import 'package:flutter_film_catalog/screens/fav_films.dart';
import 'package:flutter_film_catalog/screens/main_page.dart';
import 'package:flutter_film_catalog/tools/wrapper.dart';
import 'package:flutter_film_catalog/tools/authentication_service.dart';
import 'package:flutter_film_catalog/tools/database_service.dart';
import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:flutter_film_catalog/tools/load_tool.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthenticationService();

  final filmCountry = [
    'US',
    'UK',
    'IN',
    'FR',
    'IT',
    'RU',
    'CN',
    'JP',
    'KR'
  ];
  final _genders = ['Мужчина', 'Женщина'];
  int _selectedGenderRadio = 0;

  void _setSelectedRadio(int? value) {
    setState(() {
      _selectedGenderRadio = value!;
      gender = _genders[_selectedGenderRadio];
    });
  }

  String? firstname;
  String? lastname;
  String? description;
  String? gender;
  String? address;
  DateTime? birthday;
  String? phoneNumber;
  String phoneCountry = '375';
  bool phoneChanged = false;
  String? _filmCountry;
  String? favDirector;
  String? favActor;


  @override
  Widget build(BuildContext context) {
    Future selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() => birthday = picked);
      }
    }

    final user = Provider.of<User?>(context);

    return StreamBuilder<UserInfo>(
        stream: DatabaseService(uid: user?.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserInfo userData = snapshot.data!;
            gender = gender ?? userData.gender;
            if (gender == _genders[0]) {
              _selectedGenderRadio = 0;
            } else {
              _selectedGenderRadio = 1;
            }

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                leading: SvgPicture.asset('assets/site_logo.svg'),
                title: const Text('Профиль'),
                titleTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 18),
                automaticallyImplyLeading: false,
                backgroundColor: primaryColor,
                actionsIconTheme: const IconThemeData(),
                elevation: 0.0,
                actions: <Widget>[
                  PopupMenuButton<MenuItem>(
                    color: primaryColor,
                    iconColor: secondaryColor,
                    onSelected: (MenuItem item) {
                      switch (item) {
                        case MenuItem.Home:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Home()));
                          break;
                        case MenuItem.Logout:
                          _auth.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wrapper()));
                          break;
                        case MenuItem.Settings:
                          // TODO: Handle this case.
                          break;
                        case MenuItem.Favourites:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavFilms()));
                          break;
                      }
                    },
                    child: const Row(
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
                        value: MenuItem.Home,
                        child: Row(
                          children: [
                            Icon(Icons.list, color: secondaryColor),
                            Text('Список',
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
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(color: backgroundColor),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Данные пользователя',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Имя',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.firstname,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() => firstname = value);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Фамилия',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.lastname,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() => lastname = value);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Описание',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.description,
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              setState(() => description = value);
                            },
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Text(
                              'Пол: ',
                              style:
                              TextStyle(color: textColor, fontSize: 17),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RadioMenuButton<int>(
                                child: Text('Мужчина',
                                    style: TextStyle(
                                        color: textColor, fontSize: 17)),
                                value: 0,
                                groupValue: _selectedGenderRadio,
                                onChanged: _setSelectedRadio,
                              ),
                              RadioMenuButton<int>(
                                child: Text('Женщина',
                                    style: TextStyle(
                                        color: textColor, fontSize: 17)),
                                value: 1,
                                groupValue: _selectedGenderRadio,
                                onChanged: _setSelectedRadio,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            children: [
                              Text(
                                'Дата рождения: ',
                                style: TextStyle(fontSize: 17),
                              ),
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(
                                        DateFormat('dd.MM.yyyy').format(
                                            birthday ?? userData.birthday),
                                        style: TextStyle(
                                            fontSize: 17, color: primaryColor)),
                                    Icon(
                                      Icons.calendar_month,
                                      color: primaryColor,
                                    )
                                  ],
                                ),
                                onPressed: () => selectDate(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Адрес',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.address,
                            keyboardType: TextInputType.streetAddress,
                            onChanged: (value) {
                              setState(() => address = value);
                            },
                          ),
                          SizedBox(height: 20.0),
                          IntlPhoneField(
                            decoration: InputDecoration(
                              labelText: 'Номер телефона',
                              border: OutlineInputBorder(),
                            ),
                            dropdownTextStyle: TextStyle(fontSize: 17),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            disableLengthCheck: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: userData.phone.isEmpty
                                ? '+375'
                                : userData.phone,
                            validator: (value) {
                              if (value == null || value.number.isEmpty) {
                                return null;
                              }
                              if (value.number.length < 7 ||
                                  value.number.length > 14) {
                                return 'Некорректный номер телефона';
                              }
                              return null;
                            },
                            onChanged: (phone) => setState(() {
                              phoneNumber = phone.number;
                              phoneChanged = true;
                            }),
                            onCountryChanged: (country) {
                              setState(() {
                                phoneCountry = country.dialCode;
                                phoneChanged = true;
                              });
                            },
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Text(
                              'Любимое',
                              style: TextStyle(color: textColor, fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Text(
                                'Страна:',
                                style:
                                    TextStyle(color: textColor, fontSize: 17),
                              ),
                              Expanded(
                                child: CountryCodePicker(
                                  onChanged: (value) =>
                                      setState(() => _filmCountry = value.code),
                                  initialSelection:
                                      userData.filmCountry.isNotEmpty
                                          ? userData.filmCountry
                                          : 'US',
                                  countryFilter: filmCountry,
                                  showCountryOnly: true,
                                  showOnlyCountryWhenClosed: true,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Режиссёр',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.favDirector,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() => favDirector = value);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Актёр',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: userData.favActor,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() => favActor = value);
                            },
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor),
                                  child: Text(
                                    'Обновить',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await DatabaseService(uid: user?.uid)
                                          .updateUserData(
                                              firstname ?? userData.firstname,
                                              lastname ?? userData.lastname,
                                              description ?? userData.description,
                                              birthday ?? userData.birthday,
                                              gender ?? userData.gender,
                                              address ?? userData.address,
                                              (!phoneChanged)
                                                  ? userData.phone
                                                  : (phoneNumber!.isEmpty
                                                      ? ''
                                                      : '+' +
                                                          phoneCountry +
                                                          phoneNumber!),
                                              _filmCountry ??
                                                  userData.filmCountry,
                                              favDirector ?? userData.favDirector,
                                              favActor ?? userData.favActor);

                                      Navigator.pop(context);
                                    }
                                  }),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor),
                                  child: Text(
                                    'Удалить аккаунт',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    await _auth.deleteAccount();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Wrapper()));
                                  }),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
            );
          } else {
            return const Loading();
          }
        });
  }
}
