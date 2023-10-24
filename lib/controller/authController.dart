import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart';
import '../view/splashScreen.dart';

class AuthController extends ChangeNotifier {
  bool isloading = false;
  User? userData;
  
  Future signInAnonymous() async {
    isloading = true;
    notifyListeners();
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    navigate(userCredential.user);
    isloading = false;
    notifyListeners();
  }

  navigate(User? user) {
    if (user != null) {
      userData = user;
      showSnackBar('Sccessfully Logged In', kGreen);
      Navigator.of(getCurrentContext()).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return SplashScreen();
      }), (route) => false);
    } else {
      showSnackBar('Login Failed', kRed);
    }
  }

  signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(getCurrentContext()).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return SplashScreen();
    }), (route) => false);
  }
}
