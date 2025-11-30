import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DiceRollerApp());
}

class DiceRollerApp extends StatefulWidget {
  const DiceRollerApp({super.key});

  @override
  State<DiceRollerApp> createState() => _DiceRollerAppState();
}

class _DiceRollerAppState extends State<DiceRollerApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await _prefs;
    final saved = prefs.getBool('isDarkMode') ?? false;

    if (mounted) {
      setState(() {
        _isDarkMode = saved;
      });
    }
  }

  Future<void> _toggleTheme() async {
    final nextValue = !_isDarkMode;
    setState(() {
      _isDarkMode = nextValue;
    });

    final prefs = await _prefs;
    await prefs.setBool('isDarkMode', nextValue);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주사위 굴리기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DicePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final Future<void> Function() onToggleTheme;

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final _random = Random();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _currentDice = 1;

  @override
  void initState() {
    super.initState();
    _loadLastDice();
  }

  Future<void> _loadLastDice() async {
    final prefs = await _prefs;
    final saved = prefs.getInt('lastDice');

    if (saved != null && mounted) {
      setState(() {
        _currentDice = saved;
      });
    }
  }

  Future<void> _rollDice() async {
    final nextValue = _random.nextInt(6) + 1;

    setState(() {
      _currentDice = nextValue;
    });

    final prefs = await _prefs;
    await prefs.setInt('lastDice', nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final diceImagePath = 'assets/images/dice$_currentDice.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('주사위 굴리기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? '라이트모드로 전환' : '다크모드로 전환',
            onPressed: widget.onToggleTheme,
            icon: Text(
              widget.isDarkMode ? '☀️' : '🌙',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Image.asset(
                  diceImagePath,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _rollDice,
                  child: const Text('주사위 굴리기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
