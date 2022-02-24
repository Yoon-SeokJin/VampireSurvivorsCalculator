class ItemInfo {
  ItemInfo(
      {required this.price, required this.maxLevel, required this.imagePath});
  final int price;
  final int maxLevel;
  final String imagePath;
  int currentLevel = 0;
}

Map<String, ItemInfo> itemInfo = {
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
  'Amount': ItemInfo(price: 5000, maxLevel: 1, imagePath: 'images/Amount.png'),
  'Move speed':
      ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/MoveSpeed.png'),
  'Magnet': ItemInfo(price: 300, maxLevel: 2, imagePath: 'images/Magnet.png'),
  'Luck': ItemInfo(price: 600, maxLevel: 3, imagePath: 'images/Luck.png'),
  'Growth': ItemInfo(price: 900, maxLevel: 5, imagePath: 'images/Growth.png'),
  'Greed': ItemInfo(price: 200, maxLevel: 5, imagePath: 'images/Greed.png'),
  'Curse': ItemInfo(price: 1666, maxLevel: 5, imagePath: 'images/Curse.png'),
  'Revival':
      ItemInfo(price: 10000, maxLevel: 1, imagePath: 'images/Revival.png'),
  'Reroll': ItemInfo(price: 5000, maxLevel: 2, imagePath: 'images/Reroll.png'),
  'Skip': ItemInfo(price: 1000, maxLevel: 1, imagePath: 'images/Skip.png'),
};
