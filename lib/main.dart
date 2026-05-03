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
  String lastDebugMessage = "WELCOME! START A MATCH.";

  void updateTheme(ThemeType type) {
    currentThemeType = type;
    notifyListeners();
  }

  void updateNames(String p1, String p2) {
    player1Name = p1;
    player2Name = p2;
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
  final TextEditingController _p1 = TextEditingController(text: "Aaina");
  final TextEditingController _p2 = TextEditingController(text: "Rahul");
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
              Text("ULTIMATE\nTIC-TAC-TOE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.playerXColor)),
              const SizedBox(height: 30),
              
              Text("WHO ARE YOU?", style: TextStyle(color: theme.contrastColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              
              _buildPersonaTile(1, "Player 1 (X)", _p1, theme),
              const SizedBox(height: 10),
              _buildPersonaTile(2, "Player 2 (O)", _p2, theme),

              const SizedBox(height: 30),
              Text("SELECT THEME", style: TextStyle(color: theme.contrastColor.withOpacity(0.6), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ThemeType.values.map((t) => GestureDetector(
                  onTap: () => appState.updateTheme(t),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: appState.currentThemeType == t ? theme.contrastColor : Colors.white10, width: 3),
                      gradient: LinearGradient(colors: [GameTheme.getTheme(t).background, GameTheme.getTheme(t).secondaryBackground]),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  appState.updateNames(_p1.text, _p2.text);
                  appState.startLocalPlay();
                  appState.setDebug("LOCAL MATCH STARTED");
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                },
                child: const Text("LOCAL PASS & PLAY", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.playerXColor, foregroundColor: Colors.white, minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        appState.updateNames(_p1.text, _p2.text);
                        appState.myPlayerSymbol = (_selectedPersona == 1) ? "X" : "O";
                        appState.isLocalPlay = false;
                        _showPinDialog(context, true);
                      },
                      child: const Text("CREATE", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.playerOColor, foregroundColor: Colors.white, minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        appState.updateNames(_p1.text, _p2.text);
                        appState.myPlayerSymbol = (_selectedPersona == 1) ? "X" : "O";
                        appState.isLocalPlay = false;
                        _showPinDialog(context, false);
                      },
                      child: const Text("JOIN", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
              
              appState.setDebug("CONNECTING TO PIN: $pin...");
              
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
                  appState.setDebug("OPPONENT MOVED: ${data['subGrid']}:${data['square']}");
                } else if (data["type"] == "SYNC_SETUP") {
                  appState.updateTheme(ThemeType.values[data["theme"]]);
                  appState.updateNames(data["p1"], data["p2"]);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                  }
                } else if (data["type"] == "DRAW_VOTE") {
                  engine.castDrawVote(data["vote"], false);
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
                        width: 50, height: 50,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: theme.contrastColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
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
                        IconButton(
                          onPressed: () => appState.toggleAnalyzeMode(),
                          icon: Icon(appState.analyzeMode ? Icons.visibility : Icons.visibility_off, color: appState.analyzeMode ? theme.accentColor : theme.contrastColor, size: 28)
                        ),
                        IconButton(
                          onPressed: () => appState.toggleScoreboard(),
                          icon: Icon(appState.showScoreboard ? Icons.grid_view : Icons.grid_off, color: theme.accentColor, size: 24)
                        ),
                        IconButton(onPressed: () {
                          if (appState.isLocalPlay) {
                            engine.reset();
                          } else {
                            net.sendData({"type": "RESTART_REQUEST"});
                          }
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
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14),
                        itemCount: 9,
                        itemBuilder: (context, idx) {
                          bool isActive = appState.analyzeMode ? false : (engine.activeMiniGrid == null || engine.activeMiniGrid == idx);
                          bool isBolded = appState.analyzeMode && (engine.activeMiniGrid == null || engine.activeMiniGrid == idx);
                          return MiniBoardWidget(subGridIdx: idx, isActive: isActive, isBolded: isBolded);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Turn Indicator & Debug Msg
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Column(
                  children: [
                    Text("${turnText.toUpperCase()}'S TURN - ${appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol ? 'GO' : 'WAIT'}", 
                      style: TextStyle(color: turnColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(appState.lastDebugMessage, style: TextStyle(color: theme.contrastColor.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
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
        color: isActive ? theme.background.withOpacity(0.9) : theme.background.withOpacity(0.2),
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
                        try {
                          Provider.of<NetworkManager>(context, listen: false).sendData({"type": "MOVE", "subGrid": subGridIdx, "square": sqIdx});
                        } catch (e) {
                           appState.setDebug("NETWORK ERROR: $e");
                        }
                      }
                    } else {
                       appState.setDebug("INVALID MOVE: TARGET GRID ${engine.activeMiniGrid ?? 'ANY'}");
                    }
                  } else {
                     appState.setDebug("NOT YOUR TURN!");
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(border: Border.all(color: theme.contrastColor.withOpacity(0.15), width: 0.8)),
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
          if (win != "") IgnorePointer(child: Center(child: Opacity(opacity: 0.45, child: Text(win, style: TextStyle(fontSize: 65, fontWeight: FontWeight.w900, color: win == "X" ? theme.playerXColor : (win == "O" ? theme.playerOColor : Colors.grey)))))),
        ],
      ),
    );
  }
}
