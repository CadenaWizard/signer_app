import 'package:flutter/material.dart';
import 'colors.dart';
import 'font_sizes.dart';

class AppTextStyles {
  static final heading1 = TextStyle(
    fontSize: FontSizes.heading1,
    fontWeight: FontWeight.bold,
    color: primaryTextColor.value, // Light text for dark background
  );

  static final heading2 = TextStyle(
    fontSize: FontSizes.heading2,
    fontWeight: FontWeight.w600,
    color: primaryTextColor.value,
  );

  static final heading3 = TextStyle(
    fontSize: FontSizes.heading3,
    fontWeight: FontWeight.w500,
    color: primaryTextColor.value,
  );

  static final body = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeight.normal,
    color: subTextColor.value, // Lighter for body/secondary
  );

  static final small = TextStyle(
    fontSize: FontSizes.small,
    color: hintTextColor.value,
  );

  static final caption = TextStyle(
    fontSize: FontSizes.caption,
    color: hintTextColor.value,
  );

  static final buttonText = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeight.w600,
    color: primaryTextColor.value,
  );
}
