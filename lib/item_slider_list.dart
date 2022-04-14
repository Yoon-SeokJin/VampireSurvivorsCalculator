import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'power_up_local_storage.dart';
import 'power_up_pool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemSliderList extends StatelessWidget {
  const ItemSliderList({
    Key? key,
  }) : super(key: key);

  TableRow _buildItemSliderTile({required BuildContext context, required ItemInfo itemInfo}) {
    String name = itemInfo.getName(context);
    return TableRow(
      children: [
        SizedBox.fromSize(
          size: const Size.square(48.0),
          child: itemInfo.figure,
        ),
        Padding(
          child: Text(name, style: Theme.of(context).textTheme.headline6),
          padding: const EdgeInsets.only(left: 8.0),
        ),
        ItemSlider(itemInfo: itemInfo),
        if (itemInfo is ExtraItemInfo)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => context.read<PowerUpLocalStorage>().removeExtraItemInfos(itemInfo.id),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('item slider list rebuilt');
    var powerUpPool = context.read<PowerUpPool>();
    List<TableRow> itemSliderTileList = [];
    var itemInfos = context.watch<PowerUpLocalStorage>().itemInfos;
    for (var e in itemInfos) {
      itemSliderTileList.add(
        _buildItemSliderTile(
          context: context,
          itemInfo: e,
        ),
      );
    }

    ScrollController _scrollController = ScrollController();
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!
                  .versionInfo('0.5.0f', AppLocalizations.of(context)!.dateFormat(14, 4, 2022))),
            ),
            const Spacer(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.min),
              onPressed: () {
                powerUpPool.setMinAll();
                powerUpPool.saveSliderValue();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: Text(AppLocalizations.of(context)!.max),
                onPressed: () {
                  powerUpPool.setMaxAll();
                  powerUpPool.saveSliderValue();
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
              },
              children: itemSliderTileList,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints.expand(height: 32.0),
          child: OutlinedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddPowerUpDialog(
                  addExtraInfoCallBack: context.read<PowerUpLocalStorage>().addExtraItemInfos),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class ItemSlider extends StatelessWidget {
  const ItemSlider({
    Key? key,
    required this.itemInfo,
  }) : super(key: key);

  final ItemInfo itemInfo;

  @override
  Widget build(BuildContext context) {
    debugPrint(itemInfo.id);
    return EvenlyDividedSlider(
      value: context.select<PowerUpPool, int?>((value) => value.powerUps[itemInfo.id])!,
      max: itemInfo.maxLevel,
      divisions: max(5, itemInfo.maxLevel),
      onChanged: (value) => context.read<PowerUpPool>().setValue(itemInfo.id, value),
      onChangedEnd: (value) => context.read<PowerUpPool>().saveSliderValue(),
    );
  }
}

class EvenlyDividedSlider extends StatelessWidget {
  const EvenlyDividedSlider({
    Key? key,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.onChangedEnd,
  })  : assert(max <= divisions),
        super(key: key);
  final int value;
  final int max;
  final int divisions;
  final void Function(int)? onChanged;
  final void Function(int)? onChangedEnd;

  @override
  Widget build(BuildContext context) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    double trackShapeRadiusWidth = trackShape.getPreferredSize(true, true).width;
    return LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: (constraints.maxWidth - trackShapeRadiusWidth) * max / divisions +
              trackShapeRadiusWidth,
          child: Slider(
            label: value.toString(),
            value: value.toDouble(),
            max: max.toDouble(),
            divisions: max,
            onChanged: onChanged != null ? (double value) => onChanged!(value.toInt()) : null,
            onChangeEnd:
                onChangedEnd != null ? (double value) => onChangedEnd!(value.toInt()) : null,
          ),
        ),
      );
    });
  }
}

class AddPowerUpDialog extends StatefulWidget {
  const AddPowerUpDialog({Key? key, required this.addExtraInfoCallBack}) : super(key: key);
  final Function addExtraInfoCallBack;

  @override
  State<AddPowerUpDialog> createState() => _AddPowerUpDialogState();
}

class _AddPowerUpDialogState extends State<AddPowerUpDialog> {
  final formKey = GlobalKey<FormState>();
  String itemName = '';
  int itemPrice = 0;
  int itemMaxLevel = 0;

  int getRandomMaterialIconCodePoint() {
    int randomNumber = Random().nextInt(0x1FD3);
    late int codePoint;
    if (randomNumber < 0x1900) {
      codePoint = 0xe000 + randomNumber;
    } else {
      codePoint = 0xf0000 + randomNumber - 0x1900;
    }
    return codePoint;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addCustomPowerUpTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(AppLocalizations.of(context)!.addCustomPowerUpInfo)),
          Flexible(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.abc),
                        labelText: AppLocalizations.of(context)!.addCustomPowerUpName,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.addCustomPowerUpInputName;
                        }
                        if (value.length > 10) {
                          return AppLocalizations.of(context)!.addCustomPowerUpTooLong;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemName = value!;
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.attach_money),
                        hintText: AppLocalizations.of(context)!.addCustomPowerUpPriceHint,
                        labelText: AppLocalizations.of(context)!.addCustomPowerUpPrice + ' *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.addCustomPowerUpValidInputValue;
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return AppLocalizations.of(context)!.addCustomPowerUpValidPositive;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemPrice = int.parse(value!, radix: 10);
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.upgrade),
                        labelText: AppLocalizations.of(context)!.addCustomPowerUpMaxLevel + ' *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.addCustomPowerUpValidInputValue;
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return AppLocalizations.of(context)!.addCustomPowerUpValidPositive;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        itemMaxLevel = int.parse(value!, radix: 10);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.addCustomPowerUpCancel),
        ),
        TextButton(
          onPressed: () {
            final isValid = formKey.currentState!.validate();
            if (isValid) {
              formKey.currentState!.save();
              widget.addExtraInfoCallBack(
                  itemName, itemPrice, itemMaxLevel, getRandomMaterialIconCodePoint());
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context)!.addCustomPowerUpAdd),
        ),
      ],
    );
  }
}
