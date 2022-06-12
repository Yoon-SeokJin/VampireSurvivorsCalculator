import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/model/power_up.dart';
import '../../data/model/version_info.dart';
import '../../data/repository/power_up_repository.dart';
import '../auxiliary/power_up_calculator_result.dart';

class PowerUpCalculatorViewmodel with ChangeNotifier {
  final powerUpRepository = PowerUpRepository();
  List<PowerUpBase> powerUpList = [];
  Map<String, int> powerUpLevel = {};
  Set<String> occupiedExtraId = {};
  bool showDetail = false;
  late VersionInfo versionInfo;
  late Future<bool> ready;

  PowerUpCalculatorViewmodel() {
    ready = Future<bool>(() async {
      await dataLoad();
      return true;
    });
  }

  Future<void> dataLoad() async {
    powerUpList = await powerUpRepository.getPowerUpList();
    for (PowerUpBase e in powerUpList) {
      if (e is PowerUpExtra) {
        occupiedExtraId.add(e.id);
      }
    }
    powerUpLevel = await powerUpRepository.getPowerUpLevel();
    for (PowerUpBase e in powerUpList) {
      if (powerUpLevel.containsKey(e.id)) {
        if (powerUpLevel[e.id]! > e.maxLevel) {
          powerUpLevel[e.id] = e.maxLevel;
        } else if (powerUpLevel[e.id]! < 0) {
          powerUpLevel[e.id] = 0;
        }
      } else {
        powerUpLevel[e.id] = 0;
      }
    }
    showDetail = await powerUpRepository.getShowDetail();
    versionInfo = await powerUpRepository.getVersionInfo();
  }

  void savePowerUpExtra() {
    powerUpRepository.savePowerUpExtra(powerUpList);
  }

  void savePowerUpLevel() {
    powerUpRepository.savePowerUpLevel(powerUpLevel);
  }

  void saveShowDetail() {
    powerUpRepository.saveShowDetail(showDetail);
  }

  void removePowerUpExtra(String id) {
    powerUpList.removeWhere((element) => element.id == id);
    occupiedExtraId.remove(id);
    savePowerUpExtra();
    notifyListeners();
  }

  void setPowerUpLevel(String id, int value) {
    powerUpLevel[id] = value;
    notifyListeners();
  }

  void setPowerUpLevelAllMin() {
    for (PowerUpBase e in powerUpList) {
      powerUpLevel[e.id] = 0;
    }
    notifyListeners();
  }

  void setPowerUpLevelAllMax() {
    for (PowerUpBase e in powerUpList) {
      powerUpLevel[e.id] = e.maxLevel;
    }
    notifyListeners();
  }

  void setShowDetail(bool value) {
    showDetail = value;
    saveShowDetail();
    notifyListeners();
  }

  String getVersionInfoString(BuildContext context) {
    return AppLocalizations.of(context)!.versionInfo(
        versionInfo.version,
        AppLocalizations.of(context)!
            .dateFormat(versionInfo.date, versionInfo.month, versionInfo.year));
  }

  void addPowerUpExtra(String name, int price, int maxLevel, int iconCode) {
    int num = 0;
    while (occupiedExtraId.contains('Extra' + num.toString())) {
      ++num;
    }
    String id = 'Extra' + num.toString();
    powerUpList.add(
        PowerUpExtra(id: id, name: name, price: price, maxLevel: maxLevel, iconCode: iconCode));
    occupiedExtraId.add(id);
    powerUpLevel[id] = 0;
    savePowerUpExtra();
    notifyListeners();
  }

  List<PowerUpCalculatorResult> getResult(BuildContext context) {
    int getInflation(int basePrice, int currentLevel) =>
        basePrice * currentLevel * (currentLevel + 1) ~/ 20;

    int costCompare(PowerUpBase lhs, PowerUpBase rhs) {
      int dlhs = getInflation(lhs.price, powerUpLevel[lhs.id]!) * powerUpLevel[rhs.id]!;
      int drhs = getInflation(rhs.price, powerUpLevel[rhs.id]!) * powerUpLevel[lhs.id]!;
      return drhs.compareTo(dlhs);
    }

    List<PowerUpBase> powerUps = [
      for (PowerUpBase e in powerUpList)
        if (powerUpLevel[e.id]! > 0) e
    ];

    powerUps.sort(costCompare);

    List<int?> orders = [1];
    for (int i = 1; i < powerUps.length; ++i) {
      if (costCompare(powerUps[i - 1], powerUps[i]) != 0) {
        orders.add(i + 1);
      } else {
        orders.add(null);
      }
    }

    List<int> costs = [];
    int idx = 0;
    for (PowerUpBase e in powerUps) {
      int price = 0;
      for (int i = 0; i < powerUpLevel[e.id]!; ++i) {
        price += e.price * (i + 1) * (idx + 10) ~/ 10;
        ++idx;
      }
      costs.add(price);
    }

    List<int> costsAccumulate = [];
    for (int i = 0; i < costs.length; ++i) {
      costsAccumulate.add((i > 0 ? costsAccumulate.last : 0) + costs[i]);
    }

    List<PowerUpCalculatorResult> results = [
      for (int i = 0; i < powerUps.length; ++i)
        PowerUpCalculatorResult(
          order: orders[i],
          figure: powerUps[i].figure,
          level: powerUpLevel[powerUps[i].id]!,
          name: powerUps[i].getName(context),
          cost: costs[i],
          costAcc: costsAccumulate[i],
        )
    ];
    return results;
  }
}
