import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemmweather/utils/constant.dart';

import 'controller/authController.dart';
import 'controller/generalController.dart';
import 'view/splashScreen.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => GeneralController()),
      ],
      child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          theme: ThemeData(
              appBarTheme: AppBarTheme(
                  iconTheme: const IconThemeData(
                    color: primary,
                  ),
                  elevation: 0,
                  backgroundColor: scaffoldBodyColor,
                  titleTextStyle: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500))),
          navigatorKey: globalNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Stemm weather',
          home: const SplashScreen()),
    );
  }
}
