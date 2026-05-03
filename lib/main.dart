import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_engine.dart';
import 'theme_engine.dart';
import 'network_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UltimateTTTEngine()),
        ChangeNotifierProvider(create: (_) => NetworkManager()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const UltimateTTTApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  ThemeType currentThemeType = ThemeType.galaxy;
  String player1Name = "Aaina";
  String player2Name = "Rahul";
  String? myPlayerSymbol;
  bool showScoreboard = true;
  bool analyzeMode = false;
  bool isLocalPlay = false;

  void updateTheme(ThemeType type) {
    currentThemeType = type;
    notifyListeners();
  }

  void updateNames(String p1, String p2) {
    player1Name = p1;
    player2Name = p2;
    notifyListeners();
  }

  void toggleScoreboard() => {showScoreboard = !showScoreboard, notifyListeners()};
  void toggleAnalyzeMode() => {analyzeMode = !analyzeMode, notifyListeners()};
  void startLocalPlay() {
    isLocalPlay = true;
    myPlayerSymbol = "X";
    notifyListeners();
  }
}

class UltimateTTTApp extends StatelessWidget {
  const UltimateTTTApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _p1 = TextEditingController(text: "Aaina");
  final TextEditingController _p2 = TextEditingController(text: "Rahul");
  final TextEditingController _pin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, theme.secondaryBackground],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text("ULTIMATE TTT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.playerXColor)),
                const SizedBox(height: 30),
                TextField(controller: _p1, decoration: InputDecoration(labelText: "Player 1", labelStyle: TextStyle(color: theme.contrastColor))),
                TextField(controller: _p2, decoration: InputDecoration(labelText: "Player 2", labelStyle: TextStyle(color: theme.contrastColor))),
                const SizedBox(height: 30),
                const Text("SELECT THEME", style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ThemeType.values.map((t) => GestureDetector(
                    onTap: () => appState.updateTheme(t),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: appState.currentThemeType == t ? Colors.white : Colors.transparent, width: 2),
                        color: GameTheme.getTheme(t).background,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    appState.updateNames(_p1.text, _p2.text);
                    appState.startLocalPlay();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                  },
                  child: const Text("LOCAL PLAY", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<UltimateTTTEngine>();
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);

    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, theme.secondaryBackground],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                    Text("PLAYING", style: TextStyle(color: theme.contrastColor, fontSize: 12)),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: 9,
                        itemBuilder: (context, idx) {
                          bool isActive = engine.activeMiniGrid == null || engine.activeMiniGrid == idx;
                          return MiniBoardWidget(subGridIdx: idx, isActive: isActive);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text("${engine.currentPlayer}'S TURN", style: TextStyle(color: theme.contrastColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniBoardWidget extends StatelessWidget {
  final int subGridIdx;
  final bool isActive;
  const MiniBoardWidget({super.key, required this.subGridIdx, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<UltimateTTTEngine>();
    final theme = GameTheme.getTheme(context.watch<AppState>().currentThemeType);
    final win = engine.miniWins[subGridIdx];

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: theme.accentColor, width: 2) : null,
      ),
      child: Stack(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: 9,
            itemBuilder: (context, sqIdx) {
              String val = engine.board[subGridIdx][sqIdx];
              return GestureDetector(
                onTap: () => engine.makeMove(subGridIdx, sqIdx),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white10, width: 0.5)),
                  child: Center(child: Text(val, style: TextStyle(color: val == "X" ? theme.playerXColor : theme.playerOColor, fontWeight: FontWeight.bold))),
                ),
              );
            },
          ),
          if (win != "") Center(child: Opacity(opacity: 0.3, child: Text(win, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: win == "X" ? theme.playerXColor : theme.playerOColor)))),
        ],
      ),
    );
  }
}
