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
  bool showWonOverlays = true;
  String lastDebugMessage = "V2.0.1 READY";

  void updateTheme(ThemeType type) {
    currentThemeType = type;
    notifyListeners();
  }

  void updateNames(String p1, String p2) {
    player1Name = p1.trim().isNotEmpty ? p1 : "Player 1";
    player2Name = p2.trim().isNotEmpty ? p2 : "Player 2";
    notifyListeners();
  }

  void toggleScoreboard() {
    showScoreboard = !showScoreboard;
    notifyListeners();
  }

  void toggleAnalyzeMode() {
    analyzeMode = !analyzeMode;
    notifyListeners();
  }

  void toggleWonOverlays() {
    showWonOverlays = !showWonOverlays;
    notifyListeners();
  }

  void startLocalPlay() {
    isLocalPlay = true;
    myPlayerSymbol = "X";
    notifyListeners();
  }

  void setDebug(String msg) {
    lastDebugMessage = msg;
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
      theme: ThemeData(
        scaffoldBackgroundColor: theme.background,
        primaryColor: theme.accentColor,
      ),
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
  final TextEditingController _p1 = TextEditingController();
  final TextEditingController _p2 = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  int _selectedPersona = 1; 

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, theme.secondaryBackground],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ULTIMATE\nTIC-TAC-TOE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.playerXColor)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.help_outline, color: theme.contrastColor, size: 28),
                        onPressed: () => _showTutorialDialog(context, theme),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: theme.contrastColor, size: 28),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              Text("WHO ARE YOU?", style: TextStyle(color: theme.contrastColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              
              _buildPersonaTile(1, "Player 1 (X)", _p1, theme),
              const SizedBox(height: 10),
              _buildPersonaTile(2, "Player 2 (O)", _p2, theme),

              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  appState.updateNames(_p1.text, _p2.text);
                  appState.startLocalPlay();
                  appState.setDebug("V2.0 LOCAL PLAY");
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                },
                child: const Text("LOCAL PASS & PLAY", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.playerXColor, 
                        foregroundColor: theme.playerXColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, 
                        minimumSize: const Size(0, 55), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: theme.contrastColor.withOpacity(0.5), width: 2),
                      ),
                      onPressed: () {
                        appState.updateNames(_p1.text, _p2.text);
                        appState.myPlayerSymbol = (_selectedPersona == 1) ? "X" : "O";
                        appState.isLocalPlay = false;
                        _showPinDialog(context, true);
                      },
                      child: const Text("CREATE", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.playerOColor, 
                        foregroundColor: theme.playerOColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, 
                        minimumSize: const Size(0, 55), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: theme.contrastColor.withOpacity(0.5), width: 2),
                      ),
                      onPressed: () {
                        appState.updateNames(_p1.text, _p2.text);
                        appState.myPlayerSymbol = (_selectedPersona == 1) ? "X" : "O";
                        appState.isLocalPlay = false;
                        _showPinDialog(context, false);
                      },
                      child: const Text("JOIN", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(child: Text("VERSION 2.0.1", style: TextStyle(color: theme.contrastColor.withOpacity(0.2), fontSize: 10, letterSpacing: 1))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaTile(int index, String label, TextEditingController controller, GameTheme theme) {
    bool isSelected = _selectedPersona == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPersona = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.contrastColor.withOpacity(0.1) : Colors.black12,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? theme.accentColor : theme.contrastColor.withOpacity(0.05), width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? theme.accentColor : theme.contrastColor.withOpacity(0.2)),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(color: theme.contrastColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal),
                decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: theme.contrastColor.withOpacity(0.4), fontSize: 12), border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context, GameTheme theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("How to Play", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("1. Win a small grid to claim that spot on the big board.", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              const Text("2. Your move dictates where your opponent must play. Notice how playing in the top-right sends the opponent to the top-right large grid:", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 15),
              Center(child: SizedBox(width: 150, height: 150, child: AnimatedTutorialBoard(theme: theme))),
              const SizedBox(height: 20),
              const Text("3. If sent to a full or won grid, you get a FREE MOVE anywhere.", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              const Text("UI Toggles:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(children: const [Icon(Icons.layers, color: Colors.white54, size: 16), SizedBox(width: 8), Expanded(child: Text("Hide/Show giant won overlays.", style: TextStyle(color: Colors.white70, fontSize: 12)))]),
              const SizedBox(height: 5),
              Row(children: const [Icon(Icons.visibility, color: Colors.white54, size: 16), SizedBox(width: 8), Expanded(child: Text("Analyze Mode: 100% opacity for strategic planning.", style: TextStyle(color: Colors.white70, fontSize: 12)))]),
              const SizedBox(height: 5),
              Row(children: const [Icon(Icons.grid_view, color: Colors.white54, size: 16), SizedBox(width: 8), Expanded(child: Text("Toggle tiny Strategic Scoreboard.", style: TextStyle(color: Colors.white70, fontSize: 12)))]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("GOT IT", style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context, bool isHost) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(isHost ? "Create Room PIN" : "Join Room PIN", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: _pin,
          maxLength: 4,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 1234", hintStyle: TextStyle(color: Colors.white24)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              final pin = _pin.text;
              final appState = Provider.of<AppState>(context, listen: false);
              final net = Provider.of<NetworkManager>(context, listen: false);
              final engine = Provider.of<UltimateTTTEngine>(context, listen: false);
              
              if (isHost) {
                net.hostRoom(pin, appState.player1Name);
              } else {
                net.joinRoom(pin, appState.player2Name);
              }
              
              net.onPlayerConnected = () {
                if (isHost) {
                   net.sendData({
                     "type": "SYNC_SETUP",
                     "theme": appState.currentThemeType.index,
                     "p1": appState.player1Name,
                     "p2": appState.player2Name,
                     "board": engine.board,
                     "miniWins": engine.miniWins,
                     "activeMiniGrid": engine.activeMiniGrid,
                     "currentPlayer": engine.currentPlayer,
                   });
                   if (Navigator.canPop(context)) {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                   }
                }
              };
              
              net.onDataReceived = (data) {
                if (data["type"] == "MOVE") {
                  engine.makeMove(data["subGrid"], data["square"]);
                } else if (data["type"] == "SYNC_SETUP") {
                  appState.updateTheme(ThemeType.values[data["theme"]]);
                  appState.updateNames(data["p1"], data["p2"]);
                  
                  if (data["board"] != null) {
                    List<dynamic> bRaw = data["board"];
                    engine.board = bRaw.map((r) => (r as List<dynamic>).map((c) => c.toString()).toList()).toList();
                    List<dynamic> mwRaw = data["miniWins"];
                    engine.miniWins = mwRaw.map((e) => e.toString()).toList();
                    engine.activeMiniGrid = data["activeMiniGrid"];
                    engine.currentPlayer = data["currentPlayer"] ?? "X";
                    engine.notifyListeners();
                  }

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                  }
                } else if (data["type"] == "DRAW_VOTE") {
                  engine.castDrawVote(data["vote"], false, appState.isLocalPlay);
                } else if (data["type"] == "RESTART_REQUEST") {
                  engine.setRestartRequested(true);
                } else if (data["type"] == "RESTART_RESPONSE") {
                  if (data["accept"]) {
                    engine.reset();
                  }
                }
              };
              
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => LobbyScreen(pin: pin, isHost: isHost)));
            },
            child: const Text("GO"),
          )
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentTheme = GameTheme.getTheme(appState.currentThemeType);

    final rainbowOrder = [
      ThemeType.barbie, ThemeType.picnic, ThemeType.summer, ThemeType.plant, 
      ThemeType.ocean, ThemeType.winter, ThemeType.nighttime, ThemeType.galaxy, 
      ThemeType.sunset, ThemeType.natural, ThemeType.minimalist, ThemeType.classic, ThemeType.midnight
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
        backgroundColor: currentTheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: currentTheme.contrastColor),
        titleTextStyle: TextStyle(color: currentTheme.contrastColor),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [currentTheme.background, currentTheme.secondaryBackground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("THEME", style: TextStyle(color: currentTheme.contrastColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 15, mainAxisSpacing: 20,
                    ),
                    itemCount: rainbowOrder.length,
                    itemBuilder: (context, index) {
                      final t = rainbowOrder[index];
                      final themeInfo = GameTheme.getTheme(t);
                      final isSelected = appState.currentThemeType == t;

                      return GestureDetector(
                        onTap: () => appState.updateTheme(t),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? currentTheme.contrastColor : Colors.white10, width: isSelected ? 3 : 1),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [themeInfo.background, themeInfo.secondaryBackground],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(themeInfo.name.toUpperCase(), 
                              style: TextStyle(
                                fontSize: 9, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: currentTheme.contrastColor.withOpacity(isSelected ? 1.0 : 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LobbyScreen extends StatelessWidget {
  final String pin;
  final bool isHost;
  const LobbyScreen({super.key, required this.pin, required this.isHost});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, theme.secondaryBackground],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ROOM PIN", style: TextStyle(color: theme.contrastColor.withOpacity(0.6), letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(pin, style: TextStyle(color: theme.playerXColor, fontSize: 70, fontWeight: FontWeight.bold, letterSpacing: 10)),
              const SizedBox(height: 40),
              CircularProgressIndicator(color: theme.accentColor, strokeWidth: 5),
              const SizedBox(height: 40),
              Text("WAITING FOR OPPONENT...", 
                style: TextStyle(color: theme.contrastColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black26),
                onPressed: () {
                  Provider.of<NetworkManager>(context, listen: false).stopAll();
                  Navigator.pop(context);
                },
                child: Text("CANCEL", style: TextStyle(color: theme.contrastColor.withOpacity(0.7))),
              )
            ],
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
    final net = context.watch<NetworkManager>();

    String turnText = engine.currentPlayer == "X" ? appState.player1Name : appState.player2Name;
    Color turnColor = engine.currentPlayer == "X" ? theme.playerXColor : theme.playerOColor;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.background, theme.secondaryBackground]),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () {
                          net.stopAll();
                          engine.reset();
                          Navigator.pop(context);
                        }, icon: Icon(Icons.close, color: theme.contrastColor, size: 28)),
                        if (appState.showScoreboard)
                          Container(
                            width: 45, height: 45,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: theme.contrastColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                              itemCount: 9,
                              itemBuilder: (context, idx) {
                                String win = engine.miniWins[idx];
                                return Container(
                                  color: Colors.black12,
                                  child: Center(child: Text(win == "T" ? "T" : win, style: TextStyle(color: win == "X" ? theme.playerXColor : (win == "O" ? theme.playerOColor : Colors.transparent), fontSize: 9, fontWeight: FontWeight.w900))),
                                );
                              },
                            ),
                          ),
                        Row(
                          children: [
                            IconButton(onPressed: () => appState.toggleWonOverlays(), icon: Icon(appState.showWonOverlays ? Icons.layers : Icons.layers_clear, color: theme.contrastColor, size: 28)),
                            IconButton(onPressed: () => appState.toggleAnalyzeMode(), icon: Icon(appState.analyzeMode ? Icons.visibility : Icons.visibility_off, color: appState.analyzeMode ? theme.accentColor : theme.contrastColor, size: 28)),
                            IconButton(onPressed: () => appState.toggleScoreboard(), icon: Icon(appState.showScoreboard ? Icons.grid_view : Icons.grid_off, color: theme.accentColor, size: 24)),
                            IconButton(onPressed: () {
                              if (appState.isLocalPlay) engine.reset(); else net.sendData({"type": "RESTART_REQUEST"});
                            }, icon: Icon(Icons.refresh, color: theme.contrastColor, size: 28)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14),
                                itemCount: 9,
                                itemBuilder: (context, idx) {
                                  bool isActive = appState.analyzeMode ? false : (engine.activeMiniGrid == null || engine.activeMiniGrid == idx);
                                  bool isBolded = appState.analyzeMode && (engine.activeMiniGrid == null || engine.activeMiniGrid == idx);
                                  return MiniBoardWidget(subGridIdx: idx, isActive: isActive, isBolded: isBolded);
                                },
                              ),
                              if (engine.winningLine != null)
                                CustomPaint(
                                  size: Size.infinite,
                                  painter: WinningLinePainter(engine.winningLine!, engine.winner == "X" ? theme.playerXColor : theme.playerOColor),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    child: Column(
                      children: [
                        if (engine.winner == null) ...[
                          Text("${turnText.toUpperCase()}'S TURN - ${appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol ? 'GO' : 'WAIT'}", 
                            style: TextStyle(color: turnColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(appState.lastDebugMessage, style: TextStyle(color: theme.contrastColor.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold)),
                        ] else ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                            onPressed: () {
                              if (appState.isLocalPlay) {
                                engine.reset();
                              } else {
                                net.sendData({"type": "RESTART_REQUEST"});
                              }
                            },
                            child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ULTIMATE WIN SCREEN OVERLAY
          if (engine.winner != null)
            IgnorePointer(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(engine.winner == "DRAW" ? "IT'S A DRAW!" : "ULTIMATE WINNER", style: TextStyle(color: theme.contrastColor, fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      if (engine.winner != "DRAW")
                        Text(engine.winner == "X" ? appState.player1Name.toUpperCase() : appState.player2Name.toUpperCase(), 
                          style: TextStyle(color: engine.winner == "X" ? theme.playerXColor : theme.playerOColor, fontSize: 60, fontWeight: FontWeight.w900, letterSpacing: 5, shadows: [Shadow(color: (engine.winner == "X" ? theme.playerXColor : theme.playerOColor).withOpacity(0.5), blurRadius: 20)])),
                    ],
                  ),
                ),
              ),
            ),
          if (engine.pendingDrawVote && engine.myDrawVote == null)
            _buildDialogOverlay(
              context,
              title: "Mini-Grid Draw!",
              content: "This square ended in a tie. End the whole game in a draw?",
              actions: [
                TextButton(onPressed: () {
                  engine.castDrawVote(false, true, appState.isLocalPlay);
                  if (!appState.isLocalPlay) net.sendData({"type": "DRAW_VOTE", "vote": false});
                }, child: const Text("CONTINUE")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                  onPressed: () {
                    engine.castDrawVote(true, true, appState.isLocalPlay);
                    if (!appState.isLocalPlay) net.sendData({"type": "DRAW_VOTE", "vote": true});
                  }, 
                  child: const Text("END IN DRAW", style: TextStyle(color: Colors.white))),
              ],
            ),
          if (engine.restartRequested)
            _buildDialogOverlay(
              context,
              title: "Restart Game?",
              content: "Opponent wants to restart the match.",
              actions: [
                TextButton(onPressed: () {
                  engine.setRestartRequested(false);
                  net.sendData({"type": "RESTART_RESPONSE", "accept": false});
                }, child: const Text("DECLINE")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                  onPressed: () {
                    engine.reset();
                    net.sendData({"type": "RESTART_RESPONSE", "accept": true});
                  }, 
                  child: const Text("ACCEPT", style: TextStyle(color: Colors.white))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDialogOverlay(BuildContext context, {required String title, required String content, required List<Widget> actions}) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1a1a1a), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(content, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 25),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: actions),
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
  final bool isBolded;
  const MiniBoardWidget({super.key, required this.subGridIdx, required this.isActive, required this.isBolded});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<UltimateTTTEngine>();
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);
    final win = engine.miniWins[subGridIdx];

    return Container(
      decoration: BoxDecoration(
        color: isActive ? theme.background.withOpacity(0.8) : theme.background.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: isActive 
          ? Border.all(color: theme.accentColor, width: 4) 
          : (isBolded ? Border.all(color: theme.contrastColor.withOpacity(0.6), width: 3) : Border.all(color: theme.contrastColor.withOpacity(0.15), width: 1)),
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
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol) {
                    bool isValid = engine.canMove(subGridIdx, sqIdx);
                    if (isValid) {
                      engine.makeMove(subGridIdx, sqIdx);
                      if (!appState.isLocalPlay) {
                        Provider.of<NetworkManager>(context, listen: false).sendData({"type": "MOVE", "subGrid": subGridIdx, "square": sqIdx});
                      }
                    } else {
                      appState.setDebug("GO TO GRID ${engine.activeMiniGrid != null ? engine.activeMiniGrid! + 1 : 'ANY'}");
                    }
                  } else {
                    appState.setDebug("WAIT FOR OPPONENT");
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(border: Border.all(color: theme.contrastColor.withOpacity(0.25), width: 1.0)),
                    child: Center(
                      child: Text(val, style: TextStyle(
                        color: (val == "X" ? theme.playerXColor : theme.playerOColor).withOpacity(isActive || appState.analyzeMode ? 1.0 : 0.6), 
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      )),
                    ),
                  ),
                ),
              );
            },
          ),
          if (win != "" && appState.showWonOverlays) IgnorePointer(child: Center(child: Opacity(opacity: 0.45, child: Text(win, style: TextStyle(fontSize: 65, fontWeight: FontWeight.w900, color: win == "X" ? theme.playerXColor : (win == "O" ? theme.playerOColor : Colors.grey)))))),
        ],
      ),
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final List<int> winningLine;
  final Color color;

  WinningLinePainter(this.winningLine, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

    double getX(int idx) => (idx % 3) * (size.width / 3) + (size.width / 6);
    double getY(int idx) => (idx ~/ 3) * (size.height / 3) + (size.height / 6);

    Offset start = Offset(getX(winningLine[0]), getY(winningLine[0]));
    Offset end = Offset(getX(winningLine[2]), getY(winningLine[2]));

    Offset direction = end - start;
    double extension = 40.0;
    direction = direction / direction.distance;
    
    start -= direction * extension;
    end += direction * extension;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedTutorialBoard extends StatefulWidget {
  final GameTheme theme;
  const AnimatedTutorialBoard({super.key, required this.theme});

  @override
  State<AnimatedTutorialBoard> createState() => _AnimatedTutorialBoardState();
}

class _AnimatedTutorialBoardState extends State<AnimatedTutorialBoard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int phase = (_controller.value * 3).floor(); 
        
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: 9,
          itemBuilder: (context, macroIdx) {
            bool isTarget = phase >= 1 && macroIdx == 2; 

            return Container(
              decoration: BoxDecoration(
                color: isTarget ? widget.theme.accentColor.withOpacity(0.4) : Colors.white10,
                border: Border.all(color: isTarget ? widget.theme.accentColor : Colors.white24, width: isTarget ? 2 : 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: 9,
                itemBuilder: (context, miniIdx) {
                  bool isMove = phase >= 1 && macroIdx == 4 && miniIdx == 2;
                  return Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5)),
                    child: Center(
                      child: isMove ? Text("X", style: TextStyle(color: widget.theme.playerXColor, fontWeight: FontWeight.bold, fontSize: 10)) : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}