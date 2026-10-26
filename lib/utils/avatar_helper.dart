import 'package:flutter/material.dart';

class AvatarHelper {
  static IconData getAvatarIcon(String avatarKey) {
    switch (avatarKey) {
      case 'chef':
        return Icons.restaurant_menu_rounded;
      case 'cake':
        return Icons.cake_rounded;
      case 'pizza':
        return Icons.local_pizza_rounded;
      case 'ramen':
        return Icons.ramen_dining_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      case 'egg':
        return Icons.egg_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  static List<String> avatarKeys = [
    'chef',
    'cake',
    'pizza',
    'ramen',
    'coffee',
    'icecream',
    'egg',
    'star',
  ];
}