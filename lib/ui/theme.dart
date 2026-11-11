import 'package:flutter/material.dart';

// Paleta do Guardião: vermelho da marca, laranja de apoio, branco e preto.
const kRed = Color(0xFFEE0505); // mesmo vermelho do fundo do logo
const kRedDeep = Color(0xFFB30303);
const kOrange = Color(0xFFFF7A1A);
const kAmber = Color(0xFFFFC46B);
const kInk = Color(0xFF140A0A);
const kMist = Color(0xFFFFF1EA); // fundo claro dos campos

const kSheetRadius = 36.0;
final kPill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(40));

final guardiaoTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Fredoka', // arredondada, combina com o resto do visual
  scaffoldBackgroundColor: kRed,
  colorScheme: const ColorScheme.light(
    primary: kRed,
    onPrimary: Colors.white,
    secondary: kOrange,
    surface: Colors.white,
    onSurface: kInk,
    error: kRedDeep,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(64),
      shape: kPill,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(64),
      shape: kPill,
      foregroundColor: kInk,
      side: const BorderSide(color: kInk, width: 2),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kSheetRadius))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kMist,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: kOrange, width: 2)),
  ),
);

/// Nome do app em letras grossas com sombra "colada", pensado para a abertura.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 56, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        'Guardião',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: -size * 0.03,
          color: color,
          shadows: [Shadow(color: kInk.withValues(alpha: .3), offset: Offset(0, size * 0.06))],
        ),
      );
}
