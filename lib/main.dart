import 'package:flutter_film_catalog/models/user.dart';
import 'package:flutter_film_catalog/tools/wrapper.dart';
import 'package:flutter_film_catalog/tools/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDirectory =
  await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('userBox');
  await Hive.openBox('filmBox');
  await Hive.openBox('reviewsBox');
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthenticationService().user,
      initialData: null,
      child: const MaterialApp(
          home: Wrapper(),
        ),
    );
  }
}
