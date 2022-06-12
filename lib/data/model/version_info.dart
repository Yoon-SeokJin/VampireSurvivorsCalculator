class VersionInfo {
  final String version;
  final int year;
  final int month;
  final int date;
  const VersionInfo(
      {required this.version, required this.year, required this.month, required this.date});

  factory VersionInfo.fromSerial(dynamic data) {
    return VersionInfo(
      version: data['version'],
      year: data['year'],
      month: data['month'],
      date: data['date'],
    );
  }
}
