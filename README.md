# Vampire Survivors power up order calculator.

<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Firebase-FFCA28?&style=for-the-badge&logo=Firebase&logoColor=white"/></a>

In Vampire Survivors, power-up cost increase by 10% per number of power-ups.

So even if you bought power-ups with the same spec, the total cost varies according to the order of power-ups.

This calculator calculates the cheapest order when you bought power-ups you want.

https://vampire-survivors-calculator.web.app

![image](https://user-images.githubusercontent.com/63408412/166112825-f9abbabe-5a1f-477d-af9c-e51195dda55f.png)

# How to add new power up

1. Open `lib > item_infos.yaml`
2. Add new line fit below format
```
 - {price: (1), maxLevel: (2), imagePath: (3), id: (4)}
 (1) : cost when any power ups are bought
 (2) : max level
 (3) : icon image file path
 (4) : identifier, generally camelCase item name.
```
# How to change icon

1. Open `image`
2. Change image properly

# How to edit translation

1. Open `lib > l10n`
2. Update `app_{language code}.arb` file. (compare to `app_en`)
