import '../model/power_up.dart';
import '../model/version_info.dart';
import '../datasource/version_info_file_datasource.dart';
import '../datasource/power_up_file_datasource.dart';
import '../datasource/power_up_calculator_local_datasource.dart';

class PowerUpRepository {
  final powerUpFileDatasource = PowerUpFileDatasource();
  final powerUpCalculatorLocalDatasource = PowerUpCalculatorLocalDatasource();
  final versionInfoFileDatasource = VersionInfoFileDatasource();

  Future<List<PowerUpBase>> getPowerUpList() async {
    List<PowerUpBase> powerUpList = [];
    powerUpList += await powerUpFileDatasource.get();
    powerUpList += await powerUpCalculatorLocalDatasource.getPowerUpExtra();
    return powerUpList;
  }

  Future<Map<String, int>> getPowerUpLevel() async {
    return await powerUpCalculatorLocalDatasource.getPowerUpLevel();
  }

  Future<VersionInfo> getVersionInfo() async {
    return await versionInfoFileDatasource.get();
  }

  Future<bool> getShowDetail() async {
    return await powerUpCalculatorLocalDatasource.getShowDetail();
  }

  Future<void> savePowerUpExtra(List<PowerUpBase> powerUpBase) async {
    List<PowerUpExtra> powerUpExtraList = [
      for (PowerUpBase e in powerUpBase)
        if (e is PowerUpExtra) e
    ];
    powerUpCalculatorLocalDatasource.setPowerUpExtra(powerUpExtraList);
  }

  Future<void> savePowerUpLevel(Map<String, int> powerUpLevel) async {
    powerUpCalculatorLocalDatasource.setPowerUpLevel(powerUpLevel);
  }

  Future<void> saveShowDetail(bool showDetail) async {
    powerUpCalculatorLocalDatasource.setShowDetail(showDetail);
  }
}
