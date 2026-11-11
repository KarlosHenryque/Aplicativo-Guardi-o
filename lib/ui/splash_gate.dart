import 'package:flutter/material.dart';

import 'theme.dart';

/// Mostra a abertura (logo + nome) por um instante e depois troca para [child].
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});
  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedSwitcher(duration: const Duration(milliseconds: 600), child: _done ? widget.child : const _Splash());
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kRed,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .85, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Image.asset('assets/logo.png', width: MediaQuery.sizeOf(context).width * .8),
            ),
            const SizedBox(height: 8),
            const Wordmark(size: 64),
          ]),
        ),
      );
}
