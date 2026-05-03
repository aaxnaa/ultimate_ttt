import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_engine.dart';
import 'theme_engine.dart';
import 'network_manager.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String? myPlayerSymbol; // "X" or "O"
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
  final TextEditingController _p1Controller = TextEditingController(text: "Aaina");
  final TextEditingController _p2Controller = TextEditingController(text: "Rahul");
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);
    
    TextStyle baseStyle = GoogleFonts.getFont(theme.textStyle.fontFamily!, color: theme.contrastColor);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient - Fixed to fill entire screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.background, theme.secondaryBackground],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              children: [
                const SizedBox(height: 20),
                Text("ULTIMATE\nTIC-TAC-TOE", 
                  style: baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: theme.playerXColor)),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _p1Controller,
                  decoration: InputDecoration(
                    labelText: "Player 1 (X)", 
                    labelStyle: baseStyle.copyWith(fontSize: 14, color: theme.playerXColor.withOpacity(0.8)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.contrastColor.withOpacity(0.3))),
                  ),
                  style: baseStyle,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _p2Controller,
                  decoration: InputDecoration(
                    labelText: "Player 2 (O)", 
                    labelStyle: baseStyle.copyWith(fontSize: 14, color: theme.playerOColor.withOpacity(0.8)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.contrastColor.withOpacity(0.3))),
                  ),
                  style: baseStyle,
                ),
                
                const SizedBox(height: 40),
                Text("Select Theme:", style: baseStyle),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ThemeType.values.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => appState.updateTheme(t),
                            child: Container(
                              width: 55, height: 55,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: appState.currentThemeType == t ? theme.contrastColor : Colors.transparent,
                                  width: 3
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    GameTheme.getTheme(t).background,
                                    GameTheme.getTheme(t).secondaryBackground,
                                  ]
                                )
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(t.name.toUpperCase(), style: baseStyle.copyWith(fontSize: 9, fontWeight: FontWeight.w600, color: theme.contrastColor.withOpacity(0.6))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  onPressed: () {
                    appState.updateNames(_p1Controller.text, _p2Controller.text);
                    appState.startLocalPlay();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                  },
                  child: const Text("LOCAL PASS & PLAY", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.playerXColor,
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    appState.updateNames(_p1Controller.text, _p2Controller.text);
                    appState.isLocalPlay = false;
                    _showPinDialog(context, true);
                  },
                  child: const Text("CREATE ROOM", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.playerOColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    appState.updateNames(_p1Controller.text, _p2Controller.text);
                    appState.isLocalPlay = false;
                    _showPinDialog(context, false);
                  },
                  child: const Text("JOIN ROOM", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context, bool isHost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHost ? "Room PIN" : "Enter PIN"),
        content: TextField(
          controller: _pinController,
          maxLength: 4,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 1234"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final pin = _pinController.text;
              final appState = Provider.of<AppState>(context, listen: false);
              final net = Provider.of<NetworkManager>(context, listen: false);
              final engine = Provider.of<UltimateTTTEngine>(context, listen: false);
              
              if (isHost) {
                appState.myPlayerSymbol = "X";
                net.hostRoom(pin, appState.player1Name);
              } else {
                appState.myPlayerSymbol = "O";
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
                }
              };
              
              net.onDataReceived = (data) {
                if (data["type"] == "MOVE") {
                  engine.makeMove(data["subGrid"], data["square"]);
                } else if (data["type"] == "SYNC_SETUP") {
                  appState.updateTheme(ThemeType.values[data["theme"]]);
                  appState.updateNames(data["p1"], data["p2"]);
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
              
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
            },
            child: const Text("START"),
          )
        ],
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
    TextStyle baseStyle = GoogleFonts.getFont(theme.textStyle.fontFamily!, color: theme.contrastColor);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.background, theme.secondaryBackground],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Status Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () {
                        net.stopAll();
                        engine.reset();
                        Navigator.pop(context);
                      }, icon: Icon(Icons.close, color: theme.contrastColor, size: 24)),
                      
                      // TINY Scoreboard in Top Bar
                      if (appState.showScoreboard)
                        Container(
                          width: 48, height: 48,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.contrastColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.contrastColor.withOpacity(0.2)),
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                            itemCount: 9,
                            itemBuilder: (context, idx) {
                              String win = engine.miniWins[idx];
                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.contrastColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Center(
                                  child: Text(win == "T" ? "T" : win, style: baseStyle.copyWith(
                                    color: win == "X" ? theme.playerXColor : (win == "O" ? theme.playerOColor : theme.contrastColor.withOpacity(0.2)),
                                    fontWeight: FontWeight.bold, fontSize: 10)),
                                ),
                              );
                            },
                          ),
                        ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () => appState.toggleAnalyzeMode(),
                            icon: Icon(
                              appState.analyzeMode ? Icons.visibility : Icons.visibility_off, 
                              color: appState.analyzeMode ? theme.accentColor : theme.contrastColor, size: 24
                            ),
                          ),
                          IconButton(
                            onPressed: () => appState.toggleScoreboard(),
                            icon: Icon(
                              appState.showScoreboard ? Icons.grid_view : Icons.grid_off, 
                              color: theme.accentColor, size: 22
                            ),
                          ),
                          IconButton(onPressed: () {
                            if (appState.isLocalPlay) {
                              engine.reset();
                            } else {
                              net.sendData({"type": "RESTART_REQUEST"});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Restart request sent...", style: baseStyle.copyWith(color: Colors.white)))
                              );
                            }
                          }, icon: Icon(Icons.refresh, color: theme.contrastColor, size: 24)),
                        ],
                      ),
                    ],
                  ),
                ),

                // The Big Board (Dynamic Scaling)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14),
                          itemCount: 9,
                          itemBuilder: (context, subGridIdx) {
                            bool isActive = engine.activeMiniGrid == null || engine.activeMiniGrid == subGridIdx;
                            return MiniBoardWidget(subGridIdx: subGridIdx, isActive: isActive);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Turn Indicator
                Container(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Column(
                    children: [
                      if (engine.winner != null)
                        Text(engine.winner == "DRAW" ? "GAME ENDED IN A DRAW!" : "WINNER: ${engine.winner == "X" ? appState.player1Name : appState.player2Name}!", 
                          style: baseStyle.copyWith(fontSize: 24, color: turnColor, fontWeight: FontWeight.bold))
                      else
                        Column(
                          children: [
                            Text("${turnText.toUpperCase()}'S TURN", 
                              style: theme.textStyle.copyWith(fontSize: 20, color: turnColor, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text((appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol) ? "GO" : "WAIT", 
                              style: theme.textStyle.copyWith(fontSize: 16, color: turnColor.withOpacity(0.7), letterSpacing: 6, fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Overlays (Dialogs)
          if (engine.pendingDrawVote && engine.myDrawVote == null)
            _buildDialogOverlay(
              context,
              title: "Mini-Grid Draw!",
              content: "This square ended in a tie. End the whole game in a draw?",
              actions: [
                TextButton(onPressed: () {
                  engine.castDrawVote(false, true);
                  if (!appState.isLocalPlay) net.sendData({"type": "DRAW_VOTE", "vote": false});
                }, child: Text("CONTINUE", style: baseStyle.copyWith(fontSize: 12))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                  onPressed: () {
                    if (appState.isLocalPlay) {
                      engine.castDrawVote(true, true);
                      engine.castDrawVote(true, false);
                    } else {
                      engine.castDrawVote(true, true);
                      net.sendData({"type": "DRAW_VOTE", "vote": true});
                    }
                  }, 
                  child: const Text("END IN DRAW", style: TextStyle(fontSize: 12, color: Colors.white))),
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
                }, child: Text("DECLINE", style: baseStyle.copyWith(fontSize: 12))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                  onPressed: () {
                    engine.reset();
                    net.sendData({"type": "RESTART_RESPONSE", "accept": true});
                  }, 
                  child: const Text("ACCEPT", style: TextStyle(fontSize: 12, color: Colors.white))),
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
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
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
  const MiniBoardWidget({super.key, required this.subGridIdx, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<UltimateTTTEngine>();
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);
    final win = engine.miniWins[subGridIdx];

    bool isActuallyActive = appState.analyzeMode ? false : isActive;
    bool isBolded = appState.analyzeMode && isActive;

    return Container(
      decoration: BoxDecoration(
        color: isActuallyActive ? theme.background.withOpacity(0.9) : theme.background.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: isActuallyActive 
          ? Border.all(color: theme.accentColor, width: 3) 
          : (isBolded ? Border.all(color: theme.contrastColor.withOpacity(0.4), width: 2) : Border.all(color: Colors.transparent)),
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
                onTap: () {
                  if (appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol) {
                    engine.makeMove(subGridIdx, sqIdx);
                    if (!appState.isLocalPlay) {
                      Provider.of<NetworkManager>(context, listen: false).sendData({
                        "type": "MOVE", "subGrid": subGridIdx, "square": sqIdx
                      });
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: theme.gridColor.withOpacity(0.1), width: 0.5)),
                  child: Center(
                    child: FittedBox(
                      child: Text(val, style: TextStyle(
                        color: val == "X" 
                          ? theme.playerXColor.withOpacity(isActuallyActive || appState.analyzeMode ? 1.0 : 0.6) 
                          : theme.playerOColor.withOpacity(isActuallyActive || appState.analyzeMode ? 1.0 : 0.6),
                        fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                ),
              );
            },
          ),
          
          if (win != "")
            IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Text(win == "T" ? "T" : win, style: TextStyle(
                        color: win == "T" ? theme.contrastColor.withOpacity(0.3) : (win == "X" ? theme.playerXColor : theme.playerOColor),
                        fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
