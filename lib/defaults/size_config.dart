import 'package:flutter/material.dart';


class SizeConfig {
  static final SizeConfig _instance = SizeConfig._internal();
  factory SizeConfig() => _instance;
  SizeConfig._internal();

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static bool _initialized = false;

  void init(BuildContext context) {
    if(_initialized) return;
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    _initialized = true;
  }

  static double getProportionateScreenHeight(double inputHeight) {
    _checkInitialization();
    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateScreenWidth(double inputWidth) {
    _checkInitialization();
    return (inputWidth / 375.0) * screenWidth;
  }

  static double adaptiveSize(double size) {
    _checkInitialization();
    return size * (screenWidth / 375.0);
  }

  static void _checkInitialization() {
    if (!_initialized) {
      throw Exception('SizeConfig not initialized. Call //SizeConfig().init(context) first.');
    }
  }

  // Common sizes
  static double get defaultPadding => adaptiveSize(16);
  static double get smallFontSize => adaptiveSize(12);
  static double get mediumFontSize => adaptiveSize(16);
  static double get largeFontSize => adaptiveSize(20);
}