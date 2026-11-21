import 'package:flutter/material.dart';

/// Stark Group VMS - Theme Colors based on the Modern Fleet Redesign.
class AppColors {
  AppColors._();

  // Primary Electric Blue (Matching Buttons & Active States)
  static const primaryBlue = Color(0xFF1E60FF);
  static const primaryBlueDark = Color(0xFF0F47CF);
  static const cyanAccent = Color(0xFF38BDF8);

  // Dark Navy Sidebar Palette
  static const sidebarTop = Color(0xFF04142D);
  static const sidebarBottom = Color(0xFF08224E);
  static const brandNavy = Color(0xFF0A1F36);
  static const deepNavy = Color(0xFF14395F);
  static const deepBlue = Color(0xFF1E60FF);
  static const corporateBlue = Color(0xFF1E60FF);
  static const softBlue = Color(0xFFE0EDFF);

  // Backgrounds & Surfaces
  static const softGray = Color(0xFFF1F5F9);
  static const white = Color(0xFFFFFFFF);
  static const tableHeader = Color(0xFFF8FAFC);
  static const cardGlow = Color(0xFFEAF1FB);

  // Text colors
  static const charcoal = Color(0xFF0F172A);
  static const slate = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const textSubtle = Color(0xFF94A3B8);

  // Status Colors (Matching Redesign)
  // Active (Green)
  static const green = Color(0xFF10B981);
  static const greenBg = Color(0xFFE8F8F0);
  static const greenDark = Color(0xFF059669);

  // Maintenance (Amber / Orange)
  static const maintenance = Color(0xFFF59E0B);
  static const maintenanceBar = Color(0xFFF59E0B);
  static const maintenanceBg = Color(0xFFFFF7E6);

  // Inactive (Slate)
  static const inactive = Color(0xFF64748B);
  static const inactiveBar = Color(0xFF94A3B8);
  static const grayBg = Color(0xFFF1F5F9);

  // Error / Alert
  static const red = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEF2F2);

  // Borders
  static const border = Color(0xFFE2E8F0);
  static const inputBorder = Color(0xFFCBD5E1);
  static const tableBorder = Color(0xFFF1F5F9);

  // Gold accent (used in live preview & branding badges)
  static const goldAccent = Color(0xFFF59E0B);
}
