import 'package:flutter/material.dart';

class AppBorderRadius {
  static const radius0 = BorderRadius.all(Radius.circular(0));
  static const radius3 = BorderRadius.all(Radius.circular(3));
  static const radius4 = BorderRadius.all(Radius.circular(4));
  static const radius6 = BorderRadius.all(Radius.circular(6));
  static const radius8 = BorderRadius.all(Radius.circular(8));
  static const radius10 = BorderRadius.all(Radius.circular(10));
  static const radius16 = BorderRadius.all(Radius.circular(16));
  static const radius50 = BorderRadius.all(Radius.circular(50));  // circle

  static const radiusTop4 = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(4),
  );

  static const radiusTop6 = BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(6),
  );

  static const radiusTop24 = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  );

  static const radiusBottom4 = BorderRadius.only(
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(4),
  );

  static const radiusBottom6 = BorderRadius.only(
    bottomLeft: Radius.circular(6),
    bottomRight: Radius.circular(6),
  );
}