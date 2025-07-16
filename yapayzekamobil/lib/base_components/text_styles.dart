import 'package:flutter/material.dart';

import 'colors.dart';

const TextStyle poppins = TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black);

extension TextStyleExtensions on TextStyle {
  // weights
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);

  // colors
  TextStyle get white => copyWith(color: AppColors.white);
  TextStyle get black => copyWith(color: AppColors.black);
  TextStyle get textMiddle => copyWith(color: AppColors.textMiddle);
  TextStyle get mainColor => copyWith(color: AppColors.mainColor);
  TextStyle get redMiddle => copyWith(color: AppColors.redMiddle);
  TextStyle get gray3 => copyWith(color: AppColors.gray3);
  TextStyle get gray5 => copyWith(color: AppColors.gray5);

  // font sizes
  TextStyle get f10 => copyWith(fontSize: 10);
  TextStyle get f11 => copyWith(fontSize: 11);
  TextStyle get f12 => copyWith(fontSize: 12);
  TextStyle get f13 => copyWith(fontSize: 13);
  TextStyle get f14 => copyWith(fontSize: 14);
  TextStyle get f15 => copyWith(fontSize: 15);
  TextStyle get f16 => copyWith(fontSize: 16);
  TextStyle get f17 => copyWith(fontSize: 17);
  TextStyle get f18 => copyWith(fontSize: 18);
  TextStyle get f19 => copyWith(fontSize: 19);
  TextStyle get f20 => copyWith(fontSize: 20);
  TextStyle get f21 => copyWith(fontSize: 21);
  TextStyle get f24 => copyWith(fontSize: 24);
  TextStyle get f30 => copyWith(fontSize: 30);
  TextStyle get f36 => copyWith(fontSize: 36);

  TextStyle c(Color color) => copyWith(color: color);
  TextStyle lspacing(double? spacing) => copyWith(letterSpacing: spacing);
  TextStyle opacity(double opacity) => copyWith(
    color: color?.withOpacity(
      opacity,
    ),
  );

  // decorations
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
}
