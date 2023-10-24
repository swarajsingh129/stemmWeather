import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stemmweather/controller/authController.dart';
import 'package:stemmweather/utils/constant.dart';
import 'package:stemmweather/view/homeScreen.dart';
import 'package:stemmweather/view/signInScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<String> landingDecider() async {
    await Future.delayed(const Duration(seconds: 3));
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<AuthController>(context, listen: false).userData = user;
      return "home";
    } else {
      return "signin";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: landingDecider(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == "home") {
          return HomeScreen();
        }
        if (snapshot.data == "signin") {
          return SignInScreen();
        }

        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, Color.fromARGB(255, 255, 255, 255)],
          )),
          child: Center(
            child: Lottie.asset('assets/lottie/splash.json',
                repeat: false, width: 200),
          ),
        );
      },
    );
  }
}
