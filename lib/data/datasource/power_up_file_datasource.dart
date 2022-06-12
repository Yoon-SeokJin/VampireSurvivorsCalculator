import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../model/power_up.dart';

class PowerUpFileDatasource {
  Future<List<PowerUp>> get() async {
    String powerUpString = await rootBundle.loadString('lib/power_up_info.yaml');
    YamlList powerUpYamlList = loadYaml(powerUpString);
    List<PowerUp> powerUps = [for (var e in powerUpYamlList) PowerUp.fromSerial(e)];
    return powerUps;
  }
}
