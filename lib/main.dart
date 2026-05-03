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
        textTheme: GoogleFonts.getTextTheme(
          theme.textStyle.fontFamily!,
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: theme.contrastColor,
          displayColor: theme.contrastColor,
        ),
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
    final net = context.watch<NetworkManager>();

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Text("ULTIMATE\nTIC-TAC-TOE", 
                            style: theme.textStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: theme.playerXColor)),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: _p1Controller,
                            decoration: InputDecoration(
                              labelText: "Player 1 (X)", 
                              labelStyle: TextStyle(color: theme.playerXColor.withOpacity(0.8)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.contrastColor.withOpacity(0.3))),
                            ),
                            style: TextStyle(color: theme.contrastColor),
                          ),
                          TextField(
                            controller: _p2Controller,
                            decoration: InputDecoration(
                              labelText: "Player 2 (O)", 
                              labelStyle: TextStyle(color: theme.playerOColor.withOpacity(0.8)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.contrastColor.withOpacity(0.3))),
                            ),
                            style: TextStyle(color: theme.contrastColor),
                          ),
                          
                          const SizedBox(height: 20),
                          Text("Select Theme:", style: theme.textStyle.copyWith(color: theme.contrastColor)),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ThemeType.values.map((t) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => appState.updateTheme(t),
                                      child: Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: appState.currentThemeType == t ? theme.contrastColor : Colors.transparent,
                                            width: 2
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              GameTheme.getTheme(t).background,
                                              GameTheme.getTheme(t).secondaryBackground,
                                            ]
                                          )
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(t.name.toUpperCase(), style: TextStyle(fontSize: 10, color: theme.contrastColor.withOpacity(0.6))),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 20),
                          
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                            ),
                            onPressed: () {
                              appState.updateNames(_p1Controller.text, _p2Controller.text);
                              appState.startLocalPlay();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                            },
                            child: const Text("LOCAL PASS & PLAY", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.playerXColor,
                              foregroundColor: Colors.white, 
                              elevation: 8,
                              shadowColor: theme.playerXColor.withOpacity(0.5),
                            ),
                            onPressed: () {
                              appState.updateNames(_p1Controller.text, _p2Controller.text);
                              appState.isLocalPlay = false;
                              _showPinDialog(context, true);
                            },
                            child: const Text("CREATE ROOM", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.playerOColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: theme.playerOColor.withOpacity(0.5),
                            ),
                            onPressed: () {
                              appState.updateNames(_p1Controller.text, _p2Controller.text);
                              appState.isLocalPlay = false;
                              _showPinDialog(context, false);
                            },
                            child: const Text("JOIN ROOM", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Status Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: () {
                              net.stopAll();
                              engine.reset();
                              Navigator.pop(context);
                            }, icon: Icon(Icons.close, color: theme.contrastColor, size: 20)),
                            
                            if (appState.showScoreboard)
                              Container(
                                width: 45, height: 45,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.contrastColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
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
                                        child: Text(win == "T" ? "T" : win, style: TextStyle(
                                          color: win == "X" ? theme.playerXColor : (win == "O" ? theme.playerOColor : theme.contrastColor.withOpacity(0.3)),
                                          fontWeight: FontWeight.bold, fontSize: 8)),
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
                                    color: appState.analyzeMode ? theme.accentColor : theme.contrastColor, size: 20
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => appState.toggleScoreboard(),
                                  icon: Icon(
                                    appState.showScoreboard ? Icons.grid_view : Icons.grid_off, 
                                    color: theme.accentColor, size: 18
                                  ),
                                ),
                                IconButton(onPressed: () {
                                  if (appState.isLocalPlay) {
                                    engine.reset();
                                  } else {
                                    net.sendData({"type": "RESTART_REQUEST"});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Restart request sent..."))
                                    );
                                  }
                                }, icon: Icon(Icons.refresh, color: theme.contrastColor, size: 20)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // The Big Board (Fitted for screen)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 400,
                                height: 400,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
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
                      ),
                      
                      // Turn Indicator
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (engine.winner != null)
                              Text(engine.winner == "DRAW" ? "GAME ENDED IN A DRAW!" : "WINNER: ${engine.winner == "X" ? appState.player1Name : appState.player2Name}!", 
                                style: theme.textStyle.copyWith(fontSize: 24, color: turnColor, fontWeight: FontWeight.bold))
                            else
                              Column(
                                children: [
                                  Text("${turnText.toUpperCase()}'S TURN", 
                                    style: theme.textStyle.copyWith(fontSize: 18, color: turnColor, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text((appState.isLocalPlay || engine.currentPlayer == appState.myPlayerSymbol) ? "GO" : "WAIT", 
                                    style: theme.textStyle.copyWith(fontSize: 14, color: turnColor.withOpacity(0.7), letterSpacing: 4, fontWeight: FontWeight.bold)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Draw Vote Dialog Overlay
                  if (engine.pendingDrawVote && engine.myDrawVote == null)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: AlertDialog(
                          title: const Text("Mini-Grid Draw!"),
                          content: const Text("This square ended in a tie. End the whole game in a draw?"),
                          actions: [
                            TextButton(onPressed: () {
                              engine.castDrawVote(false, true);
                              if (!appState.isLocalPlay) net.sendData({"type": "DRAW_VOTE", "vote": false});
                            }, child: const Text("CONTINUE PLAYING")),
                            ElevatedButton(onPressed: () {
                              if (appState.isLocalPlay) {
                                engine.castDrawVote(true, true);
                                engine.castDrawVote(true, false);
                              } else {
                                engine.castDrawVote(true, true);
                                net.sendData({"type": "DRAW_VOTE", "vote": true});
                              }
                            }, child: const Text("END IN DRAW")),
                          ],
                        ),
                      ),
                    ),
                  
                  if (engine.restartRequested)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: AlertDialog(
                          title: const Text("Restart Game?"),
                          content: const Text("Opponent wants to restart the match."),
                          actions: [
                            TextButton(onPressed: () {
                              engine.setRestartRequested(false);
                              net.sendData({"type": "RESTART_RESPONSE", "accept": false});
                            }, child: const Text("DECLINE")),
                            ElevatedButton(onPressed: () {
                              engine.reset();
                              net.sendData({"type": "RESTART_RESPONSE", "accept": true});
                            }, child: const Text("ACCEPT")),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
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
      width: 120, height: 120,
      decoration: BoxDecoration(
        color: isActuallyActive ? theme.background.withOpacity(0.9) : theme.background.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: isActuallyActive 
          ? Border.all(color: theme.accentColor, width: 3) 
          : (isBolded ? Border.all(color: theme.contrastColor.withOpacity(0.5), width: 2) : Border.all(color: Colors.transparent, width: 3)),
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
                  decoration: BoxDecoration(border: Border.all(color: theme.gridColor.withOpacity(0.2), width: 0.5)),
                  child: Center(
                    child: Text(val, style: TextStyle(
                      color: val == "X" 
                        ? theme.playerXColor.withOpacity(isActuallyActive || appState.analyzeMode ? 1.0 : 0.6) 
                        : theme.playerOColor.withOpacity(isActuallyActive || appState.analyzeMode ? 1.0 : 0.6),
                      fontWeight: FontWeight.bold, fontSize: 24)),
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
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: FittedBox(
                        child: Text(win == "T" ? "T" : win, style: TextStyle(
                          color: win == "T" ? theme.contrastColor.withOpacity(0.5) : (win == "X" ? theme.playerXColor : theme.playerOColor),
                          fontWeight: FontWeight.w900)),
                      ),
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
