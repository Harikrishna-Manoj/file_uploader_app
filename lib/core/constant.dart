import 'package:flutter/material.dart';

enum MediaType { image, video }

ThemeData themeData = ThemeData(
  snackBarTheme: SnackBarThemeData(backgroundColor: Colors.purple.shade200),
  dialogBackgroundColor: Colors.purple.shade200,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);
