import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const String baseUrl = 'http://10.0.2.2:5014/api';

class AppColors {
  static const floralPink = Color(0xFFAA2E5C);
  static const lightBackground = Color(0xFFFDF6F9);
  static const greyText = Colors.grey;
  static const white = Colors.white;
}
class AppTextStyles {
  static const nameStyle = TextStyle(
    fontSize: 20, 
    fontWeight: FontWeight.bold
  );
  
  static const contactStyle = TextStyle(
    color: AppColors.greyText
  );
  
  static const appBarStyle = TextStyle(
    color: AppColors.floralPink
  );
}