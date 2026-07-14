import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────────────────────
  static const primary     = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFEFF6FF);
  static const primaryMid  = Color(0xFFBFDBFE);

  // ── Neutrals (Light) ───────────────────────────────────────────────────────
  static const bg          = Color(0xFFF8FAFC);
  static const white       = Color(0xFFFFFFFF);
  static const text        = Color(0xFF0F172A);
  static const textSec     = Color(0xFF475569);
  static const textTert    = Color(0xFF94A3B8);
  static const border      = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success     = Color(0xFF16A34A);
  static const successSoft = Color(0xFFF0FDF4);
  static const amber       = Color(0xFFD97706);
  static const amberSoft   = Color(0xFFFFFBEB);
  static const rose        = Color(0xFFDC2626);
  static const roseSoft    = Color(0xFFFEF2F2);
  static const violet      = Color(0xFF7C3AED);
  static const violetSoft  = Color(0xFFF5F3FF);
  static const teal        = Color(0xFF0891B2);
  static const tealSoft    = Color(0xFFECFEFF);
  static const indigo      = Color(0xFF4338CA);
  static const indigoSoft  = Color(0xFFEEF2FF);
  static const brown       = Color(0xFFB45309);
  static const brownSoft   = Color(0xFFFEF3C7);

  // Orange — used for 'internal' type
static const Color orange = Color(0xFFF97316);
static const Color orangeSoft = Color(0xFFFFEDD5);
static const Color darkOrangeSoft = Color(0xFF7C2D12);

// Indigo — used for 'attendance' type
static const Color indigo = Color(0xFF6366F1);
static const Color indigoSoft = Color(0xFFE0E7FF);
static const Color darkIndigoSoft = Color(0xFF312E81);

  // ── Dark Mode Neutrals ─────────────────────────────────────────────────────
  static const darkBg          = Color(0xFF0B1120); // scaffold background
  static const darkSurface     = Color(0xFF0F172A); // appbar, cards
  static const darkCard        = Color(0xFF1E293B); // elevated cards
  static const darkBorder      = Color(0xFF1E293B); // dividers, borders
  static const darkBorderLight = Color(0xFF334155); // subtle borders

  // ── Dark Mode Text ─────────────────────────────────────────────────────────
  static const darkText     = Color(0xFFF1F5F9); // primary text
  static const darkTextSec  = Color(0xFF94A3B8); // secondary text
  static const darkTextTert = Color(0xFF475569); // hint / tertiary

  // ── Dark Mode Semantic Softs ───────────────────────────────────────────────
  static const darkPrimarySoft = Color(0xFF1E3A5F);
  static const darkSuccessSoft = Color(0xFF14532D);
  static const darkRoseSoft    = Color(0xFF4C1D1D);
  static const darkAmberSoft   = Color(0xFF451A03);
  static const darkVioletSoft  = Color(0xFF2E1065);
  static const darkTealSoft    = Color(0xFF164E63);
  static const darkIndigoSoft  = Color(0xFF1E1B4B);
}
