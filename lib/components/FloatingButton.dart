import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final dynamic builder;
  final dynamic backgroundColor;

  FloatingButton({required this.builder, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => builder,
          ));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
