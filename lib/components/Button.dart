import 'package:flutter/material.dart';

Widget Button(String label, Color background, Function onClick) {
  return ElevatedButton(
    onPressed: () {
      onClick();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: background,
      padding: EdgeInsets.all(10),
    ),
    child: Text(label, style: TextStyle(color: Colors.white)),
  );
}
