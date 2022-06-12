import 'package:flutter/material.dart';

class PowerUpCalculatorResult {
  final int? order;
  final Widget figure;
  final int level;
  final String name;
  final int cost;
  final int costAcc;
  const PowerUpCalculatorResult(
      {required this.order,
      required this.figure,
      required this.level,
      required this.name,
      required this.cost,
      required this.costAcc});
}
