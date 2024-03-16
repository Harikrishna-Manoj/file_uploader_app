import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/firebase_options.dart';
import 'package:tem_file_uploader/presentation/screens/screen_upload.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const ScreenUploadFile(),
    );
  }
}
