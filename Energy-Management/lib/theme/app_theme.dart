import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFF1E1E2C),
      primaryContainer: Color(0xFF25253A),
      primaryLightRef: Color(0xFF1E1E2C),
      secondary: Color(0xFF3A3A4F),
      secondaryContainer: Color(0xFF4F4F64),
      secondaryLightRef: Color(0xFF3A3A4F),
      tertiary: Color(0xFF6A6A80),
      tertiaryContainer: Color(0xFF7F7F99),
      tertiaryLightRef: Color(0xFF6A6A80),
      appBarColor: Color(0xFF1E1E2C),
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
    ),
    subThemesData: const FlexSubThemesData(
      inputDecoratorIsFilled: true,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      useError: true,
      keepPrimary: true,
      keepSecondary: true,
      keepTertiary: true,
    ),
    tones: FlexSchemeVariant.jolly.tones(Brightness.light),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFF1E1E2C),
      primaryContainer: Color(0xFF25253A),
      primaryLightRef: Color(0xFF1E1E2C),
      secondary: Color(0xFF3A3A4F),
      secondaryContainer: Color(0xFF4F4F64),
      secondaryLightRef: Color(0xFF3A3A4F),
      tertiary: Color(0xFF6A6A80),
      tertiaryContainer: Color(0xFF7F7F99),
      tertiaryLightRef: Color(0xFF6A6A80),
      appBarColor: Color(0xFF1E1E2C),
      error: Color(0xFFFFB4AB),
      errorContainer: Color(0xFF93000A),
    ),
    subThemesData: const FlexSubThemesData(
      blendOnColors: true,
      inputDecoratorIsFilled: true,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      useError: true,
    ),
    tones: FlexSchemeVariant.jolly.tones(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
