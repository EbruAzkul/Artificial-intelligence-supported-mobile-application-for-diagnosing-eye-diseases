import 'package:flutter/material.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';

import '../colors.dart';

class NameAvatar extends StatelessWidget {
  const NameAvatar({super.key, required this.name, this.radius, this.textColor, this.backgroundColor});

  final String name;
  final double? radius;
  final Color? textColor;
  final Color? backgroundColor;

  String _getFirstLetterOfName(String fullName) {
    List<String> nameParts = fullName.split(' ');

    int startIndex = 0;
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].contains('Dr.') ||
          nameParts[i].contains('Prof.') ||
          nameParts[i].contains('Doç.') ||
          nameParts[i].contains('Op.')) {
        startIndex = i + 1;
      } else {
        break;
      }
    }

    if (startIndex < nameParts.length) {
      return nameParts[startIndex].substring(0, 1);
    }
    return fullName.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.onlyRightPaddingSmall,
      child: CircleAvatar(
        radius: radius ?? 20,
        backgroundColor: backgroundColor ?? AppColors.pageBackgroundLight,
        child: Text(
          _getFirstLetterOfName(name),
          style: poppins.w600.f16.copyWith(color: textColor ?? AppColors.textMiddle),
        ),
      ),
    );
  }
}
