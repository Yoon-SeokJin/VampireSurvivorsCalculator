import 'package:localstorage/localstorage.dart';
import '../model/power_up.dart';

class PowerUpCalculatorLocalDatasource {
  LocalStorage localStorage = LocalStorage('PowerUpCalculator');

  Future<List<PowerUpExtra>> getPowerUpExtra() async {
    List<dynamic> powerUpExtraSerial = localStorage.getItem('PowerUpExtra') ?? [];
    List<PowerUpExtra> powerUpExtraList = [
      for (dynamic e in powerUpExtraSerial) PowerUpExtra.fromSerial(e)
    ];
    return powerUpExtraList;
  }

  Future<void> setPowerUpExtra(List<PowerUpExtra> powerUpExtraList) async {
    List<Map<String, dynamic>> powerUpExtraSerial = [
      for (PowerUpExtra e in powerUpExtraList) e.toSerializable()
    ];
    await localStorage.setItem('PowerUpExtra', powerUpExtraSerial);
  }

  Future<Map<String, int>> getPowerUpLevel() async {
    Map<String, dynamic> powerUpLevelSerial = localStorage.getItem('PowerUpLevel') ?? {};
    Map<String, int> powerUpLevelList = {
      for (MapEntry<String, dynamic> e in powerUpLevelSerial.entries) e.key: e.value
    };
    return powerUpLevelList;
  }

  Future<void> setPowerUpLevel(Map<String, int> powerUpLevel) async {
    await localStorage.setItem('PowerUpLevel', powerUpLevel);
  }

  Future<bool> getShowDetail() async {
    return localStorage.getItem('showDetail') ?? false;
  }

  Future<void> setShowDetail(bool showDetail) async {
    await localStorage.setItem('showDetail', showDetail);
  }
}
