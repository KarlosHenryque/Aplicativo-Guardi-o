import 'package:flutter/material.dart';

import 'theme.dart';

/// Cabeçalho colorido em cima e uma "folha" branca que sobe por cima, com cantos de cima arredondados.
class SheetLayout extends StatelessWidget {
  const SheetLayout({
    super.key,
    required this.header,
    required this.sheet,
    this.headerFraction = .42,
    this.headerColors = const [kRed, Color(0xFFFF5A1F)],
  });

  final Widget header;
  final Widget sheet;
  final double headerFraction;
  final List<Color> headerColors;

  @override
  Widget build(BuildContext context) {
    // Tamanho da tela inteira (sem teclado): o cabeçalho não encolhe quando o teclado abre.
    final headerHeight = MediaQuery.sizeOf(context).height * headerFraction;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: headerHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: headerColors),
          ),
          child: SafeArea(bottom: false, child: header),
        ),
      ),
      Positioned.fill(
        top: headerHeight - kSheetRadius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(kSheetRadius)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomInset),
            child: sheet,
          ),
        ),
      ),
    ]);
  }
}
