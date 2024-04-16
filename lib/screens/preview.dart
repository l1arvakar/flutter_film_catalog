import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreviewImage extends StatelessWidget {
  const PreviewImage({Key? key, required this.path}) : super(key: key);

  final String path;

  Widget _loading() {
    return SizedBox(
      height: 50,
      width: 50,
      child: SpinKitChasingDots(
        color: primaryColor,
        size: 20.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFileUrl(path),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return CachedNetworkImage(
              imageUrl: snapshot.data!,
              height: 50,
              placeholder: (context, url) => _loading(),
              errorWidget: (context, url, error) => SvgPicture.asset('assets/site_logo.svg', height: 50),
            );
          } else if (snapshot.error != null || snapshot.data == null) {
            return SvgPicture.asset('assets/site_logo.svg', height: 50);
          }
        }
        return _loading();
      },
    );
  }

  Future<String?> getFileUrl(String firebasePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      try {
        String? cachedUrl = prefs.getString(firebasePath);
        if (cachedUrl != null) {
          return cachedUrl;
        }
      } catch (e) {
        print('Error reading cached URL from SharedPreferences: $e');
      }
      return null;
    }

    try {
      final downloadURL = await FirebaseStorage.instance.ref(firebasePath).getDownloadURL();
      await prefs.setString(firebasePath, downloadURL);
      return downloadURL;
    } catch (e) {
      print('Error getting download URL from Firebase Storage: $e');
      try {
        String? cachedUrl = prefs.getString(firebasePath);
        if (cachedUrl != null) {
          return cachedUrl;
        }
      } catch (e) {
        print('Error reading cached URL from SharedPreferences: $e');
      }
      return null;
    }
  }
}
