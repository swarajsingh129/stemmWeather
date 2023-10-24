import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemmweather/controller/authController.dart';
import 'package:stemmweather/utils/constant.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late AuthController authController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController = Provider.of<AuthController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<AuthController>(builder: (context, controller, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/images/splash.jpg"),
          ),
          controller.isloading
              ? progressIndicator()
              : GestureDetector(
                  onTap: () {
                    authController.signInAnonymous();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: primary,
                    ),
                    child: Text("SIGN IN ANONYMOUSLY"),
                  ),
                )
        ],
      );
    }));
  }
}
