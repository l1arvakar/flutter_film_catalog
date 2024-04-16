import 'package:flutter_film_catalog/models/user.dart';
import 'package:flutter_film_catalog/screens/authentication.dart';
import 'package:flutter_film_catalog/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return Authentication();
    } else {
      return Home();
    }
  }
}
