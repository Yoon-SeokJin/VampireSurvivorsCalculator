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

  TableRow _buildItemSliderTile(
      {required BuildContext context,
      required String itemName,
      bool removable = true}) {
    SliderComponentShape trackShape =
        SliderTheme.of(context).overlayShape ?? const RoundSliderOverlayShape();
    Size iconSize = trackShape.getPreferredSize(true, true);
    var itemInfo = context.watch<PowerUpLocalStorage>().itemInfos[itemName]!;
    String name = itemInfo is ItemInfo
        ? AppLocalizations.of(context)!.powerUpName(itemInfo.id)
        : itemName;
    print(iconSize);
    return TableRow(
      children: [
        SizedBox.fromSize(
          size: iconSize,
          child: itemInfo.figure,
        ),
        Text(name, style: Theme.of(context).textTheme.headline6),
        NewWidget(itemInfo: itemInfo, itemName: itemName),
        if (removable)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                context.read<PowerUpPool>().removeExtraPowerUp(itemName),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var powerUpPool = context.read<PowerUpPool>();
    List<TableRow> itemSliderTileList = [];
    var basicItemList = context.watch<PowerUpLocalStorage>().itemInfosRaw.keys;
    context.watch<PowerUpLocalStorage>().itemInfos.forEach(
      (key, value) {
        itemSliderTileList.add(
          _buildItemSliderTile(
            context: context,
            itemName: key,
            removable: !basicItemList.contains(key),
          ),
        );
      },
    );

    ScrollController _scrollController = ScrollController();

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!
                  .versionInfo('0.4.1', '22.04.07.')),
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
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
              },
              children: itemSliderTileList,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: FractionallySizedBox(
            widthFactor: 1,
            child: OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddPowerUpDialog(ancestorContext: context),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    Key? key,
    required this.itemInfo,
    required this.itemName,
  }) : super(key: key);

  final ItemInfoBase itemInfo;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    print("rebuild");

    return EvenlyDividedSlider(
      value: context
          .select<PowerUpPool, int>((value) => value.powerUps[itemName]!),
      max: itemInfo.maxLevel,
      divisions: max(5, itemInfo.maxLevel),
      onChanged: (value) =>
          context.read<PowerUpPool>().setValue(itemName, value),
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
    double trackShapeRadiusWidth =
        trackShape.getPreferredSize(true, true).width;
    return LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width:
              (constraints.maxWidth - trackShapeRadiusWidth) * max / divisions +
                  trackShapeRadiusWidth,
          child: Slider(
            label: value.toString(),
            value: value.toDouble(),
            max: max.toDouble(),
            divisions: max,
            onChanged: onChanged != null
                ? (double value) => onChanged!(value.toInt())
                : null,
            onChangeEnd: onChangedEnd != null
                ? (double value) => onChangedEnd!(value.toInt())
                : null,
          ),
        ),
      );
    });
  }
}

class AddPowerUpDialog extends StatefulWidget {
  const AddPowerUpDialog({Key? key, required this.ancestorContext})
      : super(key: key);
  final BuildContext ancestorContext;

  @override
  State<AddPowerUpDialog> createState() => _AddPowerUpDialogState();
}

class _AddPowerUpDialogState extends State<AddPowerUpDialog> {
  final formKey = GlobalKey<FormState>();
  String itemName = '';
  int itemPrice = 0;
  int itemMaxLevel = 0;

  @override
  Widget build(BuildContext context) {
    int randomNumber = Random().nextInt(0x1FD3);
    late int codePoint;
    if (randomNumber < 0x1900) {
      codePoint = 0xe000 + randomNumber;
    } else {
      codePoint = 0xf0000 + randomNumber - 0x1900;
    }
    IconData iconData = IconData(codePoint, fontFamily: 'MaterialIcons');
    int extraNum = 1;
    while (widget.ancestorContext
            .read<PowerUpLocalStorage>()
            .itemInfos['Extra' + extraNum.toString()] !=
        null) {
      ++extraNum;
    }
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addCustomPowerUpTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text(AppLocalizations.of(context)!.addCustomPowerUpInfo)),
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
                        labelText:
                            AppLocalizations.of(context)!.addCustomPowerUpName,
                      ),
                      initialValue: 'Extra' + extraNum.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpInputName;
                        }
                        if (widget.ancestorContext
                                .read<PowerUpLocalStorage>()
                                .itemInfos[value] !=
                            null) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpOccupied;
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
                        hintText: AppLocalizations.of(context)!
                            .addCustomPowerUpPriceHint,
                        labelText: AppLocalizations.of(context)!
                                .addCustomPowerUpPrice +
                            ' *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpValidInputValue;
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpValidPositive;
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
                        labelText: AppLocalizations.of(context)!
                                .addCustomPowerUpMaxLevel +
                            ' *',
                      ),
                      controller: TextEditingController(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpValidInputValue;
                        }
                        int? num = int.tryParse(value, radix: 10);
                        if (num == null || num <= 0) {
                          return AppLocalizations.of(context)!
                              .addCustomPowerUpValidPositive;
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
              ExtraItemInfo value = ExtraItemInfo(
                price: itemPrice,
                maxLevel: itemMaxLevel,
                icon: iconData,
              );
              widget.ancestorContext
                  .read<PowerUpLocalStorage>()
                  .addItemInfos(itemName, value);
              widget.ancestorContext
                  .read<PowerUpLocalStorage>()
                  .saveItemInfos();
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context)!.addCustomPowerUpAdd),
        ),
      ],
    );
  }
}
