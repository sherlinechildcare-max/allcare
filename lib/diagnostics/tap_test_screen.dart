import 'package:flutter/material.dart';

class TapTestScreen extends StatefulWidget {
  const TapTestScreen({super.key});

  @override
  State<TapTestScreen> createState() => _TapTestScreenState();
}

class _TapTestScreenState extends State<TapTestScreen> {
  int taps = 0;
  int buttonPress = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        taps++;
        debugPrint('TAP ANYWHERE count=$taps');
        setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tap Test')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Screen taps: $taps', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Button presses: $buttonPress', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    buttonPress++;
                    debugPrint('BUTTON PRESSED count=$buttonPress');
                    setState(() {});
                  },
                  child: const Text('PRESS ME'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
