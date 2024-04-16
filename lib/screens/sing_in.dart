import 'package:flutter_film_catalog/screens/registration.dart';
import 'package:flutter_film_catalog/tools/wrapper.dart';
import 'package:flutter_film_catalog/tools/authentication_service.dart';
import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:flutter_film_catalog/tools/load_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthenticationService _auth = AuthenticationService();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(height: 150,'assets/site_logo.svg'),
                        SizedBox(height: 20),
                        Text('Вход в систему',
                            style: TextStyle(fontSize: 24, color: textColor)),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Введите электронную почту',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите email';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => email = value);
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Введите пароль',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Пароль должен содержать минимум 8 символов';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => password = value);
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            child: Text('Войти',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result =
                                    await _auth.signInWithEmailAndPassword(
                                        email, password);
                                if (result == null) {
                                  setState(() =>
                                      error = 'Неправильный email или пароль');
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Wrapper()));
                                }
                                setState(() => loading = false);
                              }
                            }),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Registration()));
                          },
                          child: Text('Нет аккаунта? Зарегистрируйтесь',
                              style: TextStyle(color: textColor)),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          error,
                          style: TextStyle(color: accentColor, fontSize: 14.0),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
