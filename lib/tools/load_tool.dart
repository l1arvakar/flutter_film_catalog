import 'package:flutter_film_catalog/tools/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: const SpinKitChasingDots(
        color: primaryColor,
        size: 50.0,
      ),
    );
  }
}
