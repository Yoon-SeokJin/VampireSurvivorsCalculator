import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class PowerUpBase {
  final String id;
  final int price;
  final int maxLevel;
  PowerUpBase({required this.id, required this.price, required this.maxLevel});
  Map<String, dynamic> toSerializable();
  Widget get figure;
  String getName(BuildContext context);
}

class PowerUp extends PowerUpBase {
  final String imgPath;
  PowerUp({required String id, required int price, required int maxLevel, required this.imgPath})
      : super(id: id, price: price, maxLevel: maxLevel);

  factory PowerUp.fromSerial(dynamic data) {
    return PowerUp(
      id: data['id'],
      price: data['price'],
      maxLevel: data['maxLevel'],
      imgPath: data['imgPath'],
    );
  }

  @override
  Map<String, dynamic> toSerializable() {
    Map<String, dynamic> result = {
      'id': id,
      'price': price,
      'maxLevel': maxLevel,
      'imgPath': imgPath,
    };
    return result;
  }

  @override
  Widget get figure => Image.asset(
        imgPath,
        filterQuality: FilterQuality.none,
        fit: BoxFit.fill,
      );

  @override
  String getName(BuildContext context) {
    return AppLocalizations.of(context)!.powerUpName(id);
  }
}

class PowerUpExtra extends PowerUpBase {
  final int iconCode;
  final String name;
  PowerUpExtra(
      {required String id,
      required int price,
      required int maxLevel,
      required this.iconCode,
      required this.name})
      : super(id: id, price: price, maxLevel: maxLevel);

  factory PowerUpExtra.fromSerial(dynamic data) {
    return PowerUpExtra(
      id: data['id'],
      price: data['price'],
      maxLevel: data['maxLevel'],
      iconCode: data['iconCode'],
      name: data['name'],
    );
  }

  @override
  Map<String, dynamic> toSerializable() {
    Map<String, dynamic> result = {
      'id': id,
      'price': price,
      'maxLevel': maxLevel,
      'iconCode': iconCode,
      'name': name,
    };
    return result;
  }

  @override
  Widget get figure => FittedBox(
        child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons')),
        fit: BoxFit.fill,
      );

  @override
  String getName(BuildContext context) {
    return name;
  }
}
