import 'package:flutter/material.dart';

class ItemInfo {
  ItemInfo(
      {required this.price, required this.maxLevel, required this.imagePath});
  final int price;
  final int maxLevel;
  final String imagePath;
}

class PowerUpPool with ChangeNotifier {
  Map<String, ItemInfo> itemInfos = {
    'Might': ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Might.png'),
    'Armor': ItemInfo(price: 600, maxLevel: 3, imagePath: 'images/Armor.png'),
    'Max health':
        ItemInfo(price: 200, maxLevel: 3, imagePath: 'images/MaxHealth.png'),
    'Recovery':
        ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Recovery.png'),
    'Cool down':
        ItemInfo(price: 900, maxLevel: 2, imagePath: 'images/CoolDown.png'),
    'Area': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Area.png'),
    'Speed': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Speed.png'),
    'Duration':
        ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Duration.png'),
    'Amount':
        ItemInfo(price: 5000, maxLevel: 1, imagePath: 'images/Amount.png'),
    'Move speed':
        ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/MoveSpeed.png'),
    'Magnet': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Magnet.png'),
    'Luck': ItemInfo(price: 600, maxLevel: 3, imagePath: 'images/Luck.png'),
    'Growth': ItemInfo(price: 900, maxLevel: 5, imagePath: 'images/Growth.png'),
    'Greed': ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Greed.png'),
    'Curse': ItemInfo(price: 1666, maxLevel: 5, imagePath: 'images/Curse.png'),
    'Revival':
        ItemInfo(price: 10000, maxLevel: 1, imagePath: 'images/Revival.png'),
    'Reroll':
        ItemInfo(price: 5000, maxLevel: 2, imagePath: 'images/Reroll.png'),
    'Skip': ItemInfo(price: 1000, maxLevel: 2, imagePath: 'images/Skip.png'),
  };

  bool _showDetail = false;
  bool get showDetail => _showDetail;
  set showDetail(bool newValue) {
    _showDetail = newValue;
    notifyListeners();
  }

  Map<String, PowerUp> powerUps = {};
  PowerUpPool() {
    itemInfos.forEach(
      (key, value) {
        PowerUp powerUp = PowerUp();
        powerUps[key] = powerUp;
        powerUp.addListener(notifyListeners);
      },
    );
  }

  double getTextWidthMax(BuildContext context) {
    String keys = '';
    for (String key in itemInfos.keys) {
      keys += key + '\n';
    }
    final richTextWidget = Text.rich(
            TextSpan(text: keys, style: Theme.of(context).textTheme.headline6))
        .build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(const BoxConstraints.tightFor());
    return renderObject.size.width;
  }

  void setMaxAll() {
    powerUps.forEach((key, value) {
      value.value = itemInfos[key]!.maxLevel;
    });
  }

  void setMinAll() {
    powerUps.forEach((key, value) {
      value.value = 0;
    });
  }
}

class PowerUp with ChangeNotifier {
  int _value = 0;
  int get value => _value;
  set value(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}