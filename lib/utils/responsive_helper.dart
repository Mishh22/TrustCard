import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Get screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    if (width < desktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  // Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40);
    }
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(8);
      case ScreenType.tablet:
        return const EdgeInsets.all(12);
      case ScreenType.desktop:
        return const EdgeInsets.all(16);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(20);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.2;
      case ScreenType.desktop:
        return baseIconSize * 1.4;
      case ScreenType.largeDesktop:
        return baseIconSize * 1.6;
    }
  }

  // Get responsive button padding
  static EdgeInsets getResponsiveButtonPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 18);
    }
  }

  // Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.2;
      case ScreenType.desktop:
        return baseSpacing * 1.4;
      case ScreenType.largeDesktop:
        return baseSpacing * 1.6;
    }
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}
