import 'package:flutter/material.dart';

Widget LabelInput(String label) {
  return Padding(
    padding:
        const EdgeInsets.only(bottom: 5, left: 0), // Ajusta a posição do rótulo
    child: Align(
      alignment: Alignment.centerLeft, // Alinha o texto à esquerda
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
