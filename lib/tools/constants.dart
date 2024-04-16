import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)
  ),
);

const Color primaryColor = Color(0xFFCF5401); // Основной оранжевый
const Color secondaryColor = Color(0xFFFFFFFF); // Белый меню
const Color accentColor = Color(0xFFDB5461); // Коралловый
const Color backgroundColor = Color(0xFFEDEDED); // Светло-серый
const Color textColor = Color(0xFF333333); // Темно-серый
const Color highlightColor = Color(0xFF88B04B); // Желто-зеленый


enum MenuItem { Settings, Logout, Home, Favourites}