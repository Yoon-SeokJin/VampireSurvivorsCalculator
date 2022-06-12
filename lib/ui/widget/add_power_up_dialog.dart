import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPowerUpDialog extends StatefulWidget {
  const AddPowerUpDialog({Key? key, required this.addPowerUpExtraCallBack}) : super(key: key);
  final Function addPowerUpExtraCallBack;

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
              widget.addPowerUpExtraCallBack(
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
