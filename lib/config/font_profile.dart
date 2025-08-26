import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontProfile {
  // Font Sizes
  static const double small = 12.0; // For captions, secondary text
  static const double medium = 18.0; // For body text, buttons
  static const double large = 24.0; // For headings, titles

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;

  // Text Styles with Google Fonts (Roboto)
  static TextStyle smallText = GoogleFonts.ubuntu(
    fontSize: small,
    fontWeight: regular,
    letterSpacing: 0.5,
  );

  static TextStyle mediumText = GoogleFonts.ubuntu(
    fontSize: medium,
    fontWeight: regular,
    letterSpacing: 0.25,
  );

  static TextStyle largeText = GoogleFonts.ubuntu(
    fontSize: large,
    fontWeight: bold,
    letterSpacing: 0.0,
  );

  // LMS-specific styles
  static TextStyle courseTitle = GoogleFonts.ubuntu(
    fontSize: large,
    fontWeight: bold,
    letterSpacing: 0.0,
  );

  static TextStyle buttonText = GoogleFonts.ubuntu(
    fontSize: medium,
    fontWeight: bold,
    letterSpacing: 0.5,
  );

  static TextStyle caption = GoogleFonts.ubuntu(
    fontSize: small,
    fontWeight: light,
    letterSpacing: 0.5,
  );
}