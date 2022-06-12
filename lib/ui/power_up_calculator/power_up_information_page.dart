import 'package:flutter/material.dart';

class PowerUpInformationPage extends StatelessWidget {
  const PowerUpInformationPage({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: 'power_up_figure' + id,
            child: Image.asset(
              'images/Might.png',
              filterQuality: FilterQuality.none,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
