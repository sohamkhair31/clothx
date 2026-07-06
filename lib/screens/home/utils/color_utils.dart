  import 'dart:ui';

import 'package:flutter/material.dart';

Color colorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'grey':
    case 'gray':
      return Colors.grey;
    case 'brown':
      return Colors.brown;
    case 'pink':
      return Colors.pink;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    default:
      return Colors.black26;
  }
}
