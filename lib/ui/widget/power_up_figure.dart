import 'package:flutter/material.dart';
import '../power_up_calculator/power_up_information_page.dart';
import '../../data/model/power_up.dart';

class PowerUpInformationButton extends StatelessWidget {
  final PowerUp powerUp;
  const PowerUpInformationButton({required this.powerUp, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PowerUpInformationPage(id: powerUp.id)),
      ),
      child: Hero(
        tag: 'power_up_figure' + powerUp.id,
        child: powerUp.figure,
      ),
    );
  }
}
