import 'dart:math';

import 'package:flutter/material.dart';
import 'power_up_local_storage.dart';

class PowerUpPool with ChangeNotifier {
  final PowerUpLocalStorage powerUpLocalStorage;
  Map<String, int> powerUps = {};
  PowerUpPool(this.powerUpLocalStorage) {
    var values = powerUpLocalStorage.sliderValues;
    for (String key in powerUpLocalStorage.itemInfos.keys) {
      powerUps[key] =
          min(values[key]!, powerUpLocalStorage.itemInfos[key]!.maxLevel);
    }
  }

  bool _showDetail = false;
  bool get showDetail => _showDetail;
  set showDetail(bool newValue) {
    _showDetail = newValue;
    notifyListeners();
  }

  void setMinAll() {
    powerUps.forEach((key, value) {
      powerUps[key] = 0;
    });
    notifyListeners();
  }

  void setMaxAll() {
    powerUps.forEach((key, value) {
      powerUps[key] = powerUpLocalStorage.itemInfos[key]!.maxLevel;
    });
    notifyListeners();
  }

  void setValue(String key, int value) {
    powerUps[key] = value;
    notifyListeners();
  }

  void addExtraPowerUp(String key, ItemInfoBase value) {
    powerUpLocalStorage.addItemInfos(key, value);
    saveSliderValue();
  }

  void removeExtraPowerUp(String key) {
    powerUpLocalStorage.removeItemInfos(key);
    powerUps.remove(key);
    saveSliderValue();
  }

  void saveSliderValue() {
    powerUpLocalStorage.sliderValues = powerUps;
  }

  double getTextWidthMax(BuildContext context) {
    String keys = '';
    for (String key in powerUpLocalStorage.itemInfos.keys) {
      keys += key + '\n';
    }
    final richTextWidget = Text.rich(
            TextSpan(text: keys, style: Theme.of(context).textTheme.headline6))
        .build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(const BoxConstraints.tightFor());
    return renderObject.size.width;
  }
}
