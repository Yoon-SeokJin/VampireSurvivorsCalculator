import 'package:flutter/material.dart';
import 'power_up_local_storage.dart';

class PowerUpPool with ChangeNotifier {
  final PowerUpLocalStorage powerUpLocalStorage;
  PowerUpPool(this.powerUpLocalStorage) {
    debugPrint('power up pool rebuilt');
    powerUps = powerUpLocalStorage.sliderValues;
  }

  Map<String, int> powerUps = {};

  bool get showDetails => powerUpLocalStorage.showDetails;
  set showDetails(bool newValue) {
    powerUpLocalStorage.showDetails = newValue;
    notifyListeners();
  }

  void setMinAll() {
    for (var e in powerUpLocalStorage.itemInfos) {
      powerUps[e.id] = 0;
    }
    notifyListeners();
  }

  void setMaxAll() {
    for (var e in powerUpLocalStorage.itemInfos) {
      powerUps[e.id] = e.maxLevel;
    }
    notifyListeners();
  }

  void setValue(String id, int value) {
    powerUps[id] = value;
    notifyListeners();
  }

  void saveSliderValue() {
    powerUpLocalStorage.sliderValues = powerUps;
  }
}
