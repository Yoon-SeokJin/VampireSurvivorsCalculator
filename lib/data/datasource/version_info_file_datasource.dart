import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../model/version_info.dart';

class VersionInfoFileDatasource {
  Future<VersionInfo> get() async {
    String versionInfoString = await rootBundle.loadString('lib/version_info.yaml');
    YamlMap versionInfoYamlMap = loadYaml(versionInfoString);
    VersionInfo versionInfo = VersionInfo.fromSerial(versionInfoYamlMap);
    return versionInfo;
  }
}
