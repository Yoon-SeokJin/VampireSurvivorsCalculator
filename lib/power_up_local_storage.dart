import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:yaml/yaml.dart';

abstract class ItemInfoBase {
  ItemInfoBase({required this.price, required this.maxLevel});
  final int price;
  final int maxLevel;
  Widget get figure;
  Map<String, dynamic> get jsonEncodable;
}

class ItemInfo extends ItemInfoBase {
  ItemInfo({price, maxLevel, required this.imagePath, required this.id})
      : super(price: price, maxLevel: maxLevel);
  final String imagePath;
  final String id;
  @override
  Widget get figure => Image.asset(
        imagePath,
        filterQuality: FilterQuality.none,
        fit: BoxFit.fill,
      );
  @override
  Map<String, dynamic> get jsonEncodable {
    Map<String, dynamic> result = {
      'imagePath': imagePath,
      'price': price,
      'maxLevel': maxLevel,
      'id': id,
    };
    return result;
  }
}

class ExtraItemInfo extends ItemInfoBase {
  ExtraItemInfo({price, maxLevel, required this.icon})
      : super(price: price, maxLevel: maxLevel);
  IconData icon;
  @override
  Widget get figure => FittedBox(
        child: Icon(icon),
        fit: BoxFit.fill,
      );

  @override
  Map<String, dynamic> get jsonEncodable {
    Map<String, dynamic> result = {
      'icon': icon.codePoint,
      'price': price,
      'maxLevel': maxLevel,
    };
    return result;
  }
}

class PowerUpLocalStorage with ChangeNotifier {
  final LocalStorage storage;
  final YamlMap itemInfosRaw;
  Map<String, ItemInfoBase> itemInfos = {};
  PowerUpLocalStorage(this.storage, this.itemInfosRaw) {
    itemInfosRaw.forEach((key, value) {
      itemInfos[key] = ItemInfo(
        price: value['price'],
        maxLevel: value['maxLevel'],
        imagePath: value['imagePath'],
        id: value['id'],
      );
    });
    var storedItemInfos =
        Map.from(storage.getItem('powerUpStoredItemInfos') ?? {});
    storedItemInfos.forEach(
      (key, value) {
        if (itemInfos[key] == null) {
          if (value['imagePath'] != null) {
            itemInfos[key] = ItemInfo(
              imagePath: value['imagePath'],
              id: value['id'],
              price: value['price'],
              maxLevel: value['maxLevel'],
            );
          } else if (value['icon'] != null) {
            itemInfos[key] = ExtraItemInfo(
              icon: IconData(value['icon'], fontFamily: 'MaterialIcons'),
              price: value['price'],
              maxLevel: value['maxLevel'],
            );
          }
        }
      },
    );
    saveItemInfos();
  }

  void addItemInfos(String key, ItemInfoBase value) {
    itemInfos.addEntries([MapEntry(key, value)]);
    notifyListeners();
  }

  void removeItemInfos(String key) {
    itemInfos.remove(key);
    notifyListeners();
  }

  void saveItemInfos() {
    Map<String, Map> jsonSerialized = {};
    itemInfos.forEach((key, value) {
      if (!itemInfosRaw.containsKey(key)) {
        jsonSerialized[key] = value.jsonEncodable;
      }
    });
    storage.setItem('powerUpStoredItemInfos', jsonSerialized);
  }

  Map<String, int> get sliderValues {
    var values = storage.getItem('powerUpSliderValues') ?? {};
    Map<String, int> result = {
      for (String key in itemInfos.keys) key: values[key] ?? 0
    };
    return result;
  }

  set sliderValues(Map<String, int> newValues) {
    storage.setItem('powerUpSliderValues', newValues);
  }
}
