import 'package:flutter/material.dart';

//****************************************************************************//

class StyleColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blue  = Color(0xFF3740F2);

  static const Color txtMain   = black;
  static const Color txtHeader = blue;
}

//****************************************************************************//

class StyleText {
  static const TextStyle mainText = TextStyle(
      fontSize  : 24,
      height    : 24.0/24.0,
      fontWeight: FontWeight.w400,
      color     : StyleColor.txtMain,
      decoration: TextDecoration.none,
      fontFamily: 'source-sans-pro'
  );

  static const TextStyle buttonText = TextStyle(
      fontSize  : 16,
      height    : 16.0/16.0,
      fontWeight: FontWeight.w400,
      color     : StyleColor.txtMain,
      decoration: TextDecoration.none,
      fontFamily: 'source-sans-pro'
  );

  static const TextStyle header = TextStyle(
      fontSize  : 32,
      height    : 24.0/32.0,
      fontWeight: FontWeight.w700,
      color     : StyleColor.txtMain,
      decoration: TextDecoration.none,
      fontFamily: 'source-sans-pro'
  );
}