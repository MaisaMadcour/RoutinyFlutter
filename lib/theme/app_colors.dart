import 'package:flutter/material.dart';

/// Routiny color palette — ported 1:1 from the Android app's colors.xml
/// plus inline hex values found throughout the layouts.
class AppColors {
  AppColors._();

  static const white = Color(0xFFFFFFFF);

  // Brand
  static const primary = Color(0xFFC7745F); // burnt rose
  static const secondary = Color(0xFFE6B7A6); // warm pink
  static const background = Color(0xFFF7E6DE); // page background
  static const surface = Color(0xFFFFF7F3); // card/surface
  static const textDark = Color(0xFF4A2C23); // dark brown text
  static const deepChocolate = Color(0xFF5C3D2E); // primary text color
  static const chocolate = Color(0xFF3E2820);

  // Buttons
  static const buttonGradientStart = Color(0xFFBD5233);
  static const buttonGradientEnd = Color(0xFFE6B7A6);

  // Surfaces
  static const routinyBg = Color(0xFFFDF5F1); // cards / nav / sheets
  static const cardBg = Color(0xFFFDF5F1);
  static const navBg = Color(0xFFFDF5F1);

  // Bottom nav
  static const navActive = Color(0xFFBD5233);
  static const navActiveText = Color(0xFFA93B1A);
  static const navInactive = Color(0xFF8E7366);
  static const navDot = Color(0xFFBC8A7B);
  static const navRipple = Color(0xFFF2D8C9);

  // Ribbon
  static const ribbon1 = Color(0xFFC7745F);
  static const ribbon2 = Color(0xFFE8B4A2);
  static const ribbonNeutral = Color(0xFFBC8A7B);

  // Calendar
  static const calendarCardBg = Color(0xFFF5EDE6);
  static const calendarDaySelStart = Color(0xFFE19A8B);
  static const calendarDaySelEnd = Color(0xFFB86C5C);
  static const calendarTodayPillStart = Color(0xFFF2E8DD);
  static const calendarTodayPillEnd = Color(0xFFE8DCD0);
  static const calendarTodayPillText = Color(0xFFBC8A7B);
  static const calendarMonthText = Color(0xFF5C3D2E);
  static const calendarMonthArrow = Color(0xFF8E7366);
  static const calendarDayStroke = Color(0xFFE8D5CC);
  static const calendarDayNumberOnWhite = Color(0xFFC97C6D);

  // Today header
  static const todayHeaderChipBg = Color(0xFFF5E1D6);
  static const todayHeaderChipText = Color(0xFF8E5A4A);

  // Header
  static const greetingText = Color(0xFF8E7366);
  static const nameText = Color(0xFF5C3D2E);
  static const profileStroke = Color(0xFFE8D5CC);

  // Misc text
  static const secondaryText = Color(0xFF8E7366);
  static const hintText = Color(0xFFB4B0A5);
  static const mutedTab = Color(0xFF9C8B7F);
  static const danger = Color(0xFFC25C5C);
  static const warning = Color(0xFF8E5A4A);

  // Task color palette (create sheet)
  static const taskPalette = <Color>[
    Color(0xFF9DCCE7),
    Color(0xFFFFA464),
    Color(0xFF5F4031),
    Color(0xFFFBE3D9),
    Color(0xFF9EB2BB),
    Color(0xFF244E2C),
    Color(0xFFBFB14B),
  ];
  static const defaultTaskColor = Color(0xFFBC8A7B);

  // Water
  static const waterBlue = Color(0xFF5DADE2);
  static const waterDark = Color(0xFF3D8BC0);

  // Focus running digits
  static const focusPink = Color(0xFFE8607E);
  static const focusTeal = Color(0xFF3FA89B);
  static const rulerPink = Color(0xFFF25974);

  static Color parseHex(String hex) {
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }
}
