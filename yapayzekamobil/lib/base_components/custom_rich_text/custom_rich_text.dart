import 'package:flutter/material.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: poppins.w500.f13.black,
          ),
          TextSpan(
            text: text,
            style: poppins
                .w500.f13.textMiddle,
          ),
        ],
      ),
    );
  }
}
