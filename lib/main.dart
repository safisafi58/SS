import 'package:flutter/material.dart';

void main() {
  runApp(const SsApp());
}

class SsApp extends StatelessWidget {
  const SsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SS Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  final List<String> _buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
  ];

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        _calculate();
      } else {
        _expression += value;
      }
    });
  }

  void _calculate() {
    try {
      final exp = _expression.replaceAll(' ', '');
      final result = _evaluate(exp);
      _result = result == null ? 'خطا' : result.toString();
    } catch (e) {
      _result = 'خطا';
    }
  }

  double? _evaluate(String exp) {
    if (exp.isEmpty) return null;
    // Simple left-to-right evaluation with * and / first, then + and -.
    final tokens = <double>[];
    final ops = <String>[];
    var number = StringBuffer();
    for (var i = 0; i < exp.length; i++) {
      final ch = exp[i];
      if ('0123456789.'.contains(ch)) {
        number.write(ch);
      } else {
        if (number.isNotEmpty) {
          tokens.add(double.parse(number.toString()));
          number.clear();
        }
        ops.add(ch);
      }
    }
    if (number.isNotEmpty) tokens.add(double.parse(number.toString()));
    if (tokens.isEmpty || tokens.length != ops.length + 1) return null;

    var firstPass = <double>[tokens[0]];
    for (var i = 0; i < ops.length; i++) {
      if (ops[i] == '*' || ops[i] == '/') {
        final prev = firstPass.removeLast();
        final next = tokens[i + 1];
        if (ops[i] == '*') {
          firstPass.add(prev * next);
        } else {
          if (next == 0) return null;
          firstPass.add(prev / next);
        }
      } else {
        firstPass.add(tokens[i + 1]);
        ops[i] = ops[i] == '-' ? 'neg' : ops[i];
      }
    }

    // Second pass for + and -
    var result = firstPass[0];
    var idx = 1;
    for (var i = 0; i < ops.length; i++) {
      if (ops[i] == '+') {
        result += firstPass[idx++];
      } else if (ops[i] == 'neg') {
        result -= firstPass[idx++];
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SS Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: const TextStyle(fontSize: 32, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: _buttons.map((btn) {
                final isOperator = '/*-+='.contains(btn);
                return ElevatedButton(
                  onPressed: () => _onPressed(btn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btn == 'C'
                        ? Colors.red.shade400
                        : isOperator
                            ? Colors.blue.shade700
                            : Colors.grey.shade200,
                    foregroundColor: btn == 'C' || isOperator ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    btn,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
