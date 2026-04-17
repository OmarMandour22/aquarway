

import 'package:flutter/material.dart';

abstract class AppPopUp
{
  static showSnackBar (String message , BuildContext context)  =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message),)
      );
}