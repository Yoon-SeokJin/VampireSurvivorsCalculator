import 'power_up_local_storage.dart';
import 'power_up_pool.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Result {
  Result(
      {required this.itemInfo,
      required this.order,
      required this.cost,
      required this.costAccumulate});
  ItemInfo itemInfo;
  int? order;
  int cost;
  int costAccumulate;
}

class PowerUpCalculator with ChangeNotifier {
  final PowerUpPool powerUpPool;
  PowerUpCalculator(this.powerUpPool);

  int _getCostOne(int basePrice, int currentLevels, [int idx = 0]) {
    int price = 0;
    for (int i = 0; i < currentLevels; ++i) {
      price += basePrice * (i + 1) * (idx + 10) ~/ 10;
      ++idx;
    }
    return price;
  }

  List<int> _getCost(List<int> basePrices, List<int> currentLevels) {
    assert(basePrices.length == currentLevels.length);
    List<int> prices = [];
    int idx = 0;
    for (List<int> pair in IterableZip([basePrices, currentLevels])) {
      prices.add(_getCostOne(pair[0], pair[1], idx));
      idx += pair[1];
    }
    return prices;
  }

  int _getInflation(int basePrice, int currentLevel) =>
      basePrice * currentLevel * (currentLevel + 1) ~/ 20;

  List<Result> get getResult {
    var pool = powerUpPool;
    var powerUps = pool.powerUps;
    var storage = pool.powerUpLocalStorage;
    var itemInfos = storage.itemInfos;

    List<ItemInfo> items = itemInfos.where((element) => powerUps[element.id]! > 0).toList();

    int Function(ItemInfo, ItemInfo) comp = ((a, b) {
      int da = _getInflation(a.price, powerUps[a.id]!) * powerUps[b.id]!;
      int db = _getInflation(b.price, powerUps[b.id]!) * powerUps[a.id]!;
      return db.compareTo(da);
    });

    items.sort(comp);

    List<int?> orders = [1];

    for (int i = 1; i < items.length; ++i) {
      if (comp(items[i - 1], items[i]) != 0) {
        orders.add(i + 1);
      } else {
        orders.add(null);
      }
    }
    List<int> costs =
        _getCost(items.map((e) => e.price).toList(), items.map((e) => powerUps[e.id]!).toList());
    List<int> costsAccumulate = [];
    for (int cost in costs) {
      costsAccumulate.add((costsAccumulate.lastOrNull ?? 0) + cost);
    }

    List<Result> results = [];
    for (int i = 0; i < items.length; ++i) {
      results.add(Result(
        itemInfo: items[i],
        order: orders[i],
        cost: costs[i],
        costAccumulate: costsAccumulate[i],
      ));
    }
    return results;
  }
}
