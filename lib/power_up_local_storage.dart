import 'dart:math';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class ItemInfo {
  ItemInfo({required this.id, required this.price, required this.maxLevel});
  final int price;
  final int maxLevel;
  final String id;
  Widget get figure;
  String getName(BuildContext context);
}

class BaseItemInfo extends ItemInfo {
  BaseItemInfo({required id, required price, required maxLevel, required this.imagePath})
      : super(id: id, price: price, maxLevel: maxLevel);
  final String imagePath;

  @override
  Widget get figure => Image.asset(
        imagePath,
        filterQuality: FilterQuality.none,
        fit: BoxFit.fill,
      );

  @override
  String getName(BuildContext context) {
    return AppLocalizations.of(context)!.powerUpName(id);
  }
}

class ExtraItemInfo extends ItemInfo {
  ExtraItemInfo(
      {required id,
      required price,
      required maxLevel,
      required this.materialIconCodePoint,
      required this.name})
      : super(id: id, price: price, maxLevel: maxLevel);
  int materialIconCodePoint;
  String name;

  @override
  Widget get figure => FittedBox(
        child: Icon(IconData(materialIconCodePoint, fontFamily: 'MaterialIcons')),
        fit: BoxFit.fill,
      );

  Map<String, dynamic> get jsonEncodable {
    Map<String, dynamic> result = {
      'id': id,
      'name': name,
      'price': price,
      'maxLevel': maxLevel,
      'materialIconCodePoint': materialIconCodePoint,
    };
    return result;
  }

  @override
  String getName(BuildContext context) {
    return name;
  }
}

class PowerUpLocalStorage with ChangeNotifier {
  PowerUpLocalStorage(this.storage, YamlList itemInfosYaml) {
    debugPrint('local storage rebuilt');
    for (var e in itemInfosYaml) {
      itemInfos.add(BaseItemInfo(
        id: e['id'],
        price: e['price'],
        maxLevel: e['maxLevel'],
        imagePath: e['imagePath'],
      ));
    }
    List loadedExtraItemInfos = storage.getItem('powerUpExtraItemInfos') ?? [];
    for (var e in loadedExtraItemInfos) {
      itemInfos.add(ExtraItemInfo(
        id: e['id'],
        name: e['name'],
        price: e['price'],
        maxLevel: e['maxLevel'],
        materialIconCodePoint: e['materialIconCodePoint'],
      ));
      occupiedExtraId.add(_getExtraIdNum(e['id'])!);
    }
  }
  final LocalStorage storage;
  List<ItemInfo> itemInfos = [];
  Set<int> occupiedExtraId = {};

  int? _getExtraIdNum(String id) {
    RegExp regExp = RegExp(r'^Extra\d+$');
    if (!regExp.hasMatch(id)) {
      return null;
    }
    int num = int.parse(id.substring(5));
    return num;
  }

  String _getExtraId(int idNum) {
    return 'Extra$idNum';
  }

  int _getFirstUnoccupiedExtraIdNum() {
    int num = 0;
    while (occupiedExtraId.contains(num)) {
      ++num;
    }
    return num;
  }

  void addExtraItemInfos(String name, int price, int maxLevel, int materialIconCodePoint) {
    int num = _getFirstUnoccupiedExtraIdNum();
    itemInfos.add(ExtraItemInfo(
        id: _getExtraId(num),
        name: name,
        price: price,
        maxLevel: maxLevel,
        materialIconCodePoint: materialIconCodePoint));
    occupiedExtraId.add(num);
    _saveExtraItemInfos();
    notifyListeners();
  }

  void removeExtraItemInfos(String id) {
    itemInfos.removeWhere((element) => element.id == id);
    occupiedExtraId.remove(_getExtraIdNum(id)!);
    _saveExtraItemInfos();
    notifyListeners();
  }

  void _saveExtraItemInfos() {
    List<Map> jsonSerialized = [
      for (var e in itemInfos)
        if (e is ExtraItemInfo) e.jsonEncodable
    ];
    storage.setItem('powerUpExtraItemInfos', jsonSerialized);
  }

  Map<String, int> get sliderValues {
    var values = storage.getItem('powerUpSliderValues') ?? {};
    Map<String, int> result = {};
    for (var e in itemInfos) {
      result[e.id] = values[e.id] ?? 0;
      result[e.id] = min(result[e.id]!, e.maxLevel);
    }
    sliderValues = result;
    return result;
  }

  set sliderValues(Map<String, int> newValues) {
    storage.setItem('powerUpSliderValues', newValues);
  }

  bool get showDetails {
    var values = storage.getItem('powerUpShowDetails') ?? false;
    return values;
  }

  set showDetails(bool newValues) {
    storage.setItem('powerUpShowDetails', newValues);
  }
}
