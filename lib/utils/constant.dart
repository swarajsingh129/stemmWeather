import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

const primary = Color(0xFF74C4BF);
const secondary = Color(0xFFA0D8CF);
const textColor = Color(0xFF414042);
const textColorCC = Color(0xFFFFCF46);
const foodColor = Color(0xFFED6E00);
const kGreen = Color.fromARGB(255, 38, 157, 42);
const kRed = Color.fromARGB(255, 239, 30, 15);
Color? scaffoldBodyColor = Colors.grey[50];

BuildContext getCurrentContext() {
  return globalNavigatorKey.currentState!.context;
}

Widget progressIndicator() {
  return const CircularProgressIndicator(
    color: primary,
  );
}

showSnackBar(String str, Color clr) {
  ScaffoldMessenger.of(getCurrentContext()).showSnackBar(SnackBar(
    content: Text(str),
    backgroundColor: clr,
  ));
}

String formatDate(DateTime dateTime, String pattern) {
  final formatter = DateFormat(pattern);
  return formatter.format(dateTime);
}
