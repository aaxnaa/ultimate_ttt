import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'game_engine.dart';
import 'theme_engine.dart';
import 'network_manager.dart';
import 'bot_engine.dart';

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

enum HomeStage { welcome, modeSelect, localSetup, onlineChoice, onlineCreate, onlineJoin, aiSetup }
enum OverlayMode { bigSymbol, highlight, none }

class AppState extends ChangeNotifier {
  ThemeType currentThemeType = ThemeType.nighttime;
  HomeStage currentStage = HomeStage.welcome;
  OverlayMode overlayMode = OverlayMode.bigSymbol;
  
  String myName = "";
  String playerXName = "";
  String playerOName = "";
  String? myPlayerSymbol;
  
  bool showScoreboard = true;
  bool analyzeMode = false;
  bool isLocalPlay = false;
  bool isBotPlay = false;
  BotDifficulty? botDifficulty;
  String lastDebugMessage = "V2.5.2 SECURE";

  String get pXDisplay => playerXName.trim().isEmpty ? "Player X" : playerXName;
  String get pODisplay => playerOName.trim().isEmpty ? "Player O" : playerOName;

  void setStage(HomeStage stage) {
    currentStage = stage;
    notifyListeners();
  }

  void updateTheme(ThemeType type) {
    currentThemeType = type;
    notifyListeners();
  }

  void toggleOverlayMode() {
    if (overlayMode == OverlayMode.bigSymbol) overlayMode = OverlayMode.highlight;
    else if (overlayMode == OverlayMode.highlight) overlayMode = OverlayMode.none;
    else overlayMode = OverlayMode.bigSymbol;
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

  void setDebug(String msg) {
    lastDebugMessage = msg;
    notifyListeners();
  }

  void resetHome() {
    currentStage = HomeStage.welcome;
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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _p2Ctrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  String _selectedSymbol = "X";
  BotDifficulty _selectedDiff = BotDifficulty.medium;

  void _generateNewPin() {
    _pinCtrl.text = (10000 + Random().nextInt(89999)).toString();
  }

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
            colors: [theme.secondaryBackground, theme.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStageContent(context, appState, theme),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text("VERSION 2.5.2", style: TextStyle(color: theme.titleColor.withOpacity(0.2), fontSize: 10, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ULTIMATE\nTIC-TAC-TOE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.titleColor, height: 1)),
          Row(
            children: [
              IconButton(icon: Icon(Icons.help_outline, color: theme.titleColor), onPressed: () => showTutorialDialog(context, theme)),
              IconButton(icon: Icon(Icons.palette_outlined, color: theme.titleColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent(BuildContext context, AppState appState, GameTheme theme) {
    switch (appState.currentStage) {
      case HomeStage.welcome: return _buildWelcome(appState, theme);
      case HomeStage.modeSelect: return _buildModeSelect(appState, theme);
      case HomeStage.localSetup: return _buildLocalSetup(appState, theme);
      case HomeStage.onlineChoice: return _buildOnlineChoice(appState, theme);
      case HomeStage.onlineCreate: return _buildOnlineCreate(appState, theme);
      case HomeStage.onlineJoin: return _buildOnlineJoin(appState, theme);
      case HomeStage.aiSetup: return _buildAiSetup(appState, theme);
    }
  }

  Widget _buildWelcome(AppState appState, GameTheme theme) {
    return Column(children: [
      const SizedBox(height: 40),
      _sectionLabel(theme, "GET STARTED"),
      const SizedBox(height: 12),
      TextField(controller: _nameCtrl, style: TextStyle(color: theme.titleColor, fontWeight: FontWeight.bold), decoration: _inputDeco(theme, "Your Name")),
      const SizedBox(height: 40),
      _bigBtn(theme, "CONTINUE", theme.accentColor, theme.createTextColor, () {
        appState.myName = _nameCtrl.text.isEmpty ? "Player" : _nameCtrl.text;
        appState.setStage(HomeStage.modeSelect);
      }),
    ]);
  }

  Widget _buildModeSelect(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "SELECT GAME MODE"),
      const SizedBox(height: 20),
      _modeBtn(theme, "LOCAL PASS OR PLAY\n(SAME DEVICE)", Icons.phonelink_setup, () => appState.setStage(HomeStage.localSetup)),
      const SizedBox(height: 15),
      _modeBtn(theme, "PLAY VS HUMAN (ONLINE)", Icons.public, () => appState.setStage(HomeStage.onlineChoice)),
      const SizedBox(height: 15),
      _modeBtn(theme, "PLAY VS AI", Icons.smart_toy_outlined, () => appState.setStage(HomeStage.aiSetup)),
      const SizedBox(height: 30),
      TextButton(onPressed: () => appState.setStage(HomeStage.welcome), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _buildLocalSetup(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "LOCAL PLAY SETUP"),
      const SizedBox(height: 20),
      TextField(controller: _p2Ctrl, style: TextStyle(color: theme.titleColor), decoration: _inputDeco(theme, "Opponent Name")),
      const SizedBox(height: 25),
      _settingsPreview(theme),
      const SizedBox(height: 30),
      _bigBtn(theme, "START MATCH", theme.accentColor, theme.createTextColor, () {
        appState.isLocalPlay = true;
        appState.isBotPlay = false;
        appState.playerXName = appState.myName;
        appState.playerOName = _p2Ctrl.text.isEmpty ? "Player 2" : _p2Ctrl.text;
        appState.myPlayerSymbol = "X";
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
      }),
      TextButton(onPressed: () => appState.setStage(HomeStage.modeSelect), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _buildOnlineChoice(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "MULTIPLAYER"),
      const SizedBox(height: 20),
      _bigBtn(theme, "CREATE A ROOM", theme.accentColor, theme.createTextColor, () {
        _generateNewPin();
        appState.setStage(HomeStage.onlineCreate);
      }),
      const SizedBox(height: 15),
      _bigBtn(theme, "JOIN A ROOM", theme.accentColor2, theme.joinTextColor, () {
        _pinCtrl.clear();
        appState.setStage(HomeStage.onlineJoin);
      }),
      const SizedBox(height: 30),
      TextButton(onPressed: () => appState.setStage(HomeStage.modeSelect), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _buildOnlineCreate(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "YOUR UNIQUE ROOM CODE"),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.accentColor, width: 2)),
        child: Text(_pinCtrl.text, style: TextStyle(color: theme.titleColor, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 8)),
      ),
      const SizedBox(height: 25),
      _symbolPicker(theme),
      const SizedBox(height: 25),
      _settingsPreview(theme),
      const SizedBox(height: 30),
      _bigBtn(theme, "CREATE & WAIT", theme.accentColor, theme.createTextColor, () {
        appState.myPlayerSymbol = _selectedSymbol;
        if (_selectedSymbol == "X") {
          appState.playerXName = appState.myName;
          appState.playerOName = "Waiting...";
        } else {
          appState.playerOName = appState.myName;
          appState.playerXName = "Waiting...";
        }
        _startOnlineGame(context, _pinCtrl.text, true);
      }),
      TextButton(onPressed: () => appState.setStage(HomeStage.onlineChoice), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _buildOnlineJoin(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "ENTER ROOM CODE"),
      const SizedBox(height: 20),
      TextField(
        controller: _pinCtrl, maxLength: 5, keyboardType: TextInputType.number, 
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.titleColor, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5), 
        decoration: _inputDeco(theme, "e.g. 12345")
      ),
      const SizedBox(height: 30),
      _bigBtn(theme, "JOIN MATCH", theme.accentColor2, theme.joinTextColor, () {
        if (_pinCtrl.text.length == 5) {
          _startOnlineGame(context, _pinCtrl.text, false);
        } else {
          appState.setDebug("PIN MUST BE 5 DIGITS");
        }
      }),
      TextButton(onPressed: () => appState.setStage(HomeStage.onlineChoice), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _buildAiSetup(AppState appState, GameTheme theme) {
    return Column(children: [
      _sectionLabel(theme, "VS TIC-TAC-TRON"),
      const SizedBox(height: 20),
      _aiDiffPickerV2(theme),
      const SizedBox(height: 25),
      _symbolPicker(theme),
      const SizedBox(height: 25),
      _settingsPreview(theme),
      const SizedBox(height: 30),
      _bigBtn(theme, "START AI MATCH", theme.accentColor, theme.createTextColor, () {
        appState.isLocalPlay = false;
        appState.isBotPlay = true;
        appState.botDifficulty = _selectedDiff;
        if (_selectedSymbol == "X") {
          appState.playerXName = appState.myName;
          appState.playerOName = "Tic-Tac-Tron";
          appState.myPlayerSymbol = "X";
        } else {
          appState.playerOName = appState.myName;
          appState.playerXName = "Tic-Tac-Tron";
          appState.myPlayerSymbol = "O";
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
      }),
      TextButton(onPressed: () => appState.setStage(HomeStage.modeSelect), child: Text("BACK", style: TextStyle(color: theme.titleColor.withOpacity(0.5)))),
    ]);
  }

  Widget _settingsPreview(GameTheme theme) {
    final appState = context.watch<AppState>();
    
    String overlayDesc = "";
    if (appState.overlayMode == OverlayMode.bigSymbol) overlayDesc = "BIG ICONS";
    else if (appState.overlayMode == OverlayMode.highlight) overlayDesc = "COLOR SHADE";
    else overlayDesc = "CLEAN VIEW";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(15), border: Border.all(color: theme.titleColor.withOpacity(0.1))),
      child: Column(
        children: [
          _settingRow(theme, "THEME", theme.name.toUpperCase(), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          const SizedBox(height: 12),
          _settingRow(theme, "OVERLAY", overlayDesc, () => appState.toggleOverlayMode()),
          const SizedBox(height: 12),
          _settingRow(theme, "SCOREBOARD", appState.showScoreboard ? "ON" : "OFF", () => appState.toggleScoreboard()),
          const SizedBox(height: 12),
          _settingRow(theme, "ANALYZE (EYE)", appState.analyzeMode ? "ON" : "OFF", () => appState.toggleAnalyzeMode()),
        ],
      ),
    );
  }

  Widget _settingRow(GameTheme theme, String label, String value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.titleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: theme.titleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(value, style: TextStyle(color: theme.titleColor, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(GameTheme theme, String text) => Text(text, style: TextStyle(color: theme.titleColor.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2), textAlign: TextAlign.center);

  Widget _modeBtn(GameTheme theme, String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.titleColor.withOpacity(0.1))),
        child: Row(children: [
          Icon(icon, color: theme.accentColor, size: 30),
          const SizedBox(width: 20),
          Expanded(child: Text(text, style: TextStyle(color: theme.titleColor, fontWeight: FontWeight.bold, fontSize: 14))),
        ]),
      ),
    );
  }

  Widget _bigBtn(GameTheme theme, String text, Color bgColor, Color textColor, VoidCallback onTap) {
    Color finalTextColor = textColor;
    if (bgColor.computeLuminance() > 0.7 && textColor.computeLuminance() > 0.7) { finalTextColor = Colors.black87; }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor, foregroundColor: finalTextColor, minimumSize: const Size(double.infinity, 60), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 10, shadowColor: bgColor.withOpacity(0.4),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  InputDecoration _inputDeco(GameTheme theme, String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: theme.titleColor.withOpacity(0.3)), filled: true, fillColor: Colors.black12,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(20), counterText: "",
  );

  Widget _symbolPicker(GameTheme theme) {
    return Row(children: ["X", "O"].map((s) => Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSymbol = s),
        child: Container(
          margin: EdgeInsets.only(right: s == "X" ? 10 : 0, left: s == "O" ? 10 : 0),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _selectedSymbol == s ? (s == "X" ? theme.playerXColor : theme.playerOColor).withOpacity(0.2) : Colors.black12,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _selectedSymbol == s ? (s == "X" ? theme.playerXColor : theme.playerOColor) : Colors.transparent, width: 3),
          ),
          child: Center(child: Text(s, style: TextStyle(color: s == "X" ? theme.playerXColor : theme.playerOColor, fontSize: 28, fontWeight: FontWeight.bold))),
        ),
      ),
    )).toList());
  }

  Widget _aiDiffPickerV2(GameTheme theme) {
    final diffs = [
      {'val': BotDifficulty.easy, 'label': 'EASY', 'icon': Icons.sentiment_satisfied_alt},
      {'val': BotDifficulty.medium, 'label': 'MED', 'icon': Icons.sentiment_neutral},
      {'val': BotDifficulty.hard, 'label': 'HARD', 'icon': Icons.sentiment_very_dissatisfied},
      {'val': BotDifficulty.extraHard, 'label': 'PRO', 'icon': Icons.psychology},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(15)),
      child: Row(children: diffs.map((d) {
        bool isSel = _selectedDiff == d['val'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDiff = d['val'] as BotDifficulty),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? theme.accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(d['icon'] as IconData, size: 18, color: isSel ? theme.createTextColor : theme.titleColor.withOpacity(0.4)),
                  const SizedBox(height: 4),
                  Text(d['label'] as String, style: TextStyle(color: isSel ? theme.createTextColor : theme.titleColor.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      }).toList()),
    );
  }

  void _startOnlineGame(BuildContext context, String pin, bool isHost) {
    final appState = Provider.of<AppState>(context, listen: false);
    final net = Provider.of<NetworkManager>(context, listen: false);
    final engine = Provider.of<UltimateTTTEngine>(context, listen: false);

    net.onDataReceived = (data) {
      if (isHost && data["type"] == "JOIN_REQ") {
        if (appState.myPlayerSymbol == "X") { appState.playerOName = data["name"]; } 
        else { appState.playerXName = data["name"]; }
        appState.notifyListeners();
        net.sendData({
           "type": "SYNC_ACCEPT",
           "theme": appState.currentThemeType.index,
           "pX": appState.playerXName,
           "pO": appState.playerOName,
           "hostSymbol": appState.myPlayerSymbol,
           "board": engine.board,
           "miniWins": engine.miniWins,
           "activeMiniGrid": engine.activeMiniGrid,
           "currentPlayer": engine.currentPlayer,
        });
        if (Navigator.canPop(context)) { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())); }
      } else if (!isHost && data["type"] == "SYNC_ACCEPT") {
        appState.updateTheme(ThemeType.values[data["theme"]]);
        appState.playerXName = data["pX"];
        appState.playerOName = data["pO"];
        appState.myPlayerSymbol = data["hostSymbol"] == "X" ? "O" : "X";
        List<dynamic> bRaw = data["board"];
        engine.board = bRaw.map((r) => (r as List<dynamic>).map((c) => c.toString()).toList()).toList();
        List<dynamic> mwRaw = data["miniWins"];
        engine.miniWins = mwRaw.map((e) => e.toString()).toList();
        engine.activeMiniGrid = data["activeMiniGrid"];
        engine.currentPlayer = data["currentPlayer"] ?? "X";
        engine.notifyListeners();
        if (Navigator.canPop(context)) { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())); }
      } else if (data["type"] == "MOVE") {
        engine.forceRemoteMove(data["subGrid"], data["square"], data["player"]);
      } else if (data["type"] == "RESTART_REQUEST") {
        engine.setRestartRequested(true);
      } else if (data["type"] == "RESTART_RESPONSE") {
        if (data["accept"]) engine.reset();
      }
    };

    if (isHost) net.hostRoom(pin, appState.myName);
    else net.joinRoom(pin, appState.myName);

    Navigator.push(context, MaterialPageRoute(builder: (_) => LobbyScreen(pin: pin, isHost: isHost)));
  }
}

void showTutorialDialog(BuildContext context, GameTheme theme) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("OFFICIAL RULES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _rule("1. X ALWAYS STARTS", "The first move of the match is always made by Player X."),
            _rule("2. THE SEND-AWAY RULE", "Where you play in a small grid determines which small grid your opponent must play in next."),
            _rule("3. CLAIMING GRIDS", "Win 3-in-a-row in a small grid to claim that spot on the big board."),
            _rule("4. FREE MOVES", "If your opponent sends you to a grid that is 100% full, you get a FREE MOVE anywhere on the board."),
            _rule("5. ULTIMATE WIN", "Win 3 large grids in a row to win the entire game!"),
            const SizedBox(height: 15),
            Center(child: SizedBox(width: 150, height: 150, child: AnimatedTutorialBoard(theme: theme))),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("GOT IT", style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold)))],
    ),
  );
}

Widget _rule(String title, String desc) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]),
);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentTheme = GameTheme.getTheme(appState.currentThemeType);
    final rainbowOrder = ThemeType.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('THEMES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
        backgroundColor: currentTheme.secondaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: currentTheme.titleColor),
        titleTextStyle: TextStyle(color: currentTheme.titleColor),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [currentTheme.secondaryBackground, currentTheme.background]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 30),
              itemCount: rainbowOrder.length,
              itemBuilder: (context, index) {
                final t = rainbowOrder[index];
                final themeInfo = GameTheme.getTheme(t);
                final isSelected = appState.currentThemeType == t;
                return GestureDetector(
                  onTap: () => appState.updateTheme(t),
                  child: Column(children: [
                    Expanded(child: Container(decoration: BoxDecoration(
                      shape: BoxShape.circle, border: Border.all(color: isSelected ? currentTheme.titleColor : Colors.white10, width: isSelected ? 4 : 1),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [themeInfo.secondaryBackground, themeInfo.background]),
                    ))),
                    const SizedBox(height: 8),
                    Text(themeInfo.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: currentTheme.titleColor.withOpacity(isSelected ? 1.0 : 0.6)), overflow: TextOverflow.ellipsis),
                  ]),
                );
              },
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
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.secondaryBackground, theme.background])),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("ROOM PIN", style: TextStyle(color: theme.titleColor.withOpacity(0.6), letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(pin, style: TextStyle(color: theme.playerXColor, fontSize: 70, fontWeight: FontWeight.bold, letterSpacing: 10)),
          const SizedBox(height: 40),
          CircularProgressIndicator(color: theme.accentColor, strokeWidth: 5),
          const SizedBox(height: 40),
          Text("WAITING FOR OPPONENT...", style: TextStyle(color: theme.titleColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 60),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black26), onPressed: () {
            Provider.of<NetworkManager>(context, listen: false).stopAll();
            Navigator.pop(context);
          }, child: Text("CANCEL", style: TextStyle(color: theme.titleColor.withOpacity(0.7)))),
        ])),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BotEngine? _bot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.isBotPlay && appState.botDifficulty != null) {
        final engine = Provider.of<UltimateTTTEngine>(context, listen: false);
        String botSym = appState.myPlayerSymbol == "X" ? "O" : "X";
        _bot = BotEngine(engine: engine, difficulty: appState.botDifficulty!, botSymbol: botSym);
        engine.addListener(_onEngineChanged);
        if (botSym == "X" && engine.board.every((g) => g.every((s) => s == ""))) { _bot!.makeMove(); }
      }
    });
  }

  void _onEngineChanged() {
    final engine = Provider.of<UltimateTTTEngine>(context, listen: false);
    if (engine.currentPlayer == _bot?.botSymbol && _bot != null) { _bot!.makeMove(); }
  }

  @override
  void dispose() {
    final engine = Provider.of<UltimateTTTEngine>(context, listen: false);
    engine.removeListener(_onEngineChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<UltimateTTTEngine>();
    final appState = context.watch<AppState>();
    final theme = GameTheme.getTheme(appState.currentThemeType);
    final net = context.watch<NetworkManager>();

    String turnText = engine.currentPlayer == "X" ? appState.pXDisplay : appState.pODisplay;
    Color turnColor = engine.currentPlayer == "X" ? theme.playerXColor : theme.playerOColor;

    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.secondaryBackground, theme.background])),
          child: SafeArea(child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () { net.stopAll(); engine.reset(); appState.resetHome(); Navigator.pop(context); }, icon: Icon(Icons.close, color: theme.titleColor)),
              if (appState.showScoreboard)
                Container(width: 45, height: 45, padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: theme.titleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2), itemCount: 9,
                    itemBuilder: (context, idx) {
                      String win = engine.miniWins[idx];
                      return Container(color: Colors.black12, child: Center(child: Text(win, style: TextStyle(color: win == "X" ? theme.playerXColor : theme.playerOColor, fontSize: 9, fontWeight: FontWeight.w900))));
                    })),
              Row(children: [
                IconButton(onPressed: () => showTutorialDialog(context, theme), icon: Icon(Icons.help_outline, color: theme.titleColor)),
                IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: Icon(Icons.palette_outlined, color: theme.titleColor)),
                IconButton(onPressed: () => appState.toggleAnalyzeMode(), icon: Icon(appState.analyzeMode ? Icons.visibility : Icons.visibility_off, color: appState.analyzeMode ? theme.accentColor : theme.titleColor)),
                IconButton(onPressed: () => appState.toggleOverlayMode(), icon: Icon(appState.overlayMode == OverlayMode.bigSymbol ? Icons.layers : (appState.overlayMode == OverlayMode.highlight ? Icons.square : Icons.layers_clear), color: theme.titleColor)),
                IconButton(onPressed: () { if (appState.isLocalPlay || appState.isBotPlay) engine.reset(); else net.sendData({"type": "RESTART_REQUEST"}); }, icon: Icon(Icons.refresh, color: theme.titleColor)),
              ]),
            ])),
            Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(20), child: AspectRatio(aspectRatio: 1, child: Stack(children: [
              GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14), itemCount: 9,
                itemBuilder: (context, idx) {
                  bool isActive = appState.analyzeMode ? false : (engine.activeMiniGrid == null || engine.activeMiniGrid == idx);
                  return MiniBoardWidget(subGridIdx: idx, isActive: isActive);
                }),
              if (engine.winningLine != null) CustomPaint(size: Size.infinite, painter: WinningLinePainter(engine.winningLine!, engine.winner == "X" ? theme.playerXColor : theme.playerOColor)),
            ]))))),
            Padding(padding: const EdgeInsets.only(bottom: 40, top: 20), child: Column(children: [
              if (engine.winner == null) ...[
                Text("${turnText.toUpperCase()}'S TURN", style: TextStyle(color: turnColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(appState.lastDebugMessage, style: TextStyle(color: theme.titleColor.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold)),
              ]
            ])),
          ])),
        ),

        // ULTIMATE WIN SCREEN OVERLAY
        if (engine.winner != null)
          Container(color: Colors.black.withOpacity(0.9), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(engine.winner == "DRAW" ? "IT'S A DRAW!" : "ULTIMATE WINNER", style: TextStyle(color: theme.contrastColor, fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (engine.winner != "DRAW")
              Text(engine.winner == "X" ? appState.pXDisplay.toUpperCase() : appState.pODisplay.toUpperCase(), 
                style: TextStyle(color: engine.winner == "X" ? theme.playerXColor : theme.playerOColor, fontSize: 60, fontWeight: FontWeight.w900, letterSpacing: 5)),
            const SizedBox(height: 60),
            _winBtn(theme, "PLAY AGAIN", theme.accentColor, theme.createTextColor, () { 
               engine.reset(); 
               if (appState.isBotPlay && _bot?.botSymbol == "X") _bot!.makeMove(); 
               if (!appState.isLocalPlay && !appState.isBotPlay) net.sendData({"type": "RESTART_REQUEST"}); 
            }),
            const SizedBox(height: 15),
            _winBtn(theme, "BACK TO HOME", theme.accentColor2, theme.joinTextColor, () { 
               net.stopAll(); 
               engine.reset(); 
               appState.resetHome(); 
               Navigator.pop(context); 
            }),
          ]))),
          
        if (engine.restartRequested)
          _buildDialogOverlay(context, title: "Restart Game?", content: "Opponent wants to restart the match.", actions: [
            TextButton(onPressed: () { engine.setRestartRequested(false); net.sendData({"type": "RESTART_RESPONSE", "accept": false}); }, child: Text("DECLINE", style: TextStyle(color: theme.titleColor))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, foregroundColor: theme.createTextColor), onPressed: () { engine.reset(); net.sendData({"type": "RESTART_RESPONSE", "accept": true}); }, child: const Text("ACCEPT")),
          ]),
      ]),
    );
  }

  Widget _winBtn(GameTheme theme, String text, Color bgColor, Color textColor, VoidCallback onTap) {
    Color finalTextColor = textColor;
    if (bgColor.computeLuminance() > 0.7 && textColor.computeLuminance() > 0.7) { finalTextColor = Colors.black87; }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: bgColor, foregroundColor: finalTextColor, minimumSize: const Size(250, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 10),
      onPressed: onTap, child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }

  Widget _buildDialogOverlay(BuildContext context, {required String title, required String content, required List<Widget> actions}) => Container(
    color: Colors.black87, child: Center(child: Container(width: 300, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF1a1a1a), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text(content, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: actions),
      ]),
    )),
  );
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

    Color? highlightColor;
    if (win != "" && appState.overlayMode == OverlayMode.highlight) {
      highlightColor = (win == "X" ? theme.playerXColor : theme.playerOColor).withOpacity(0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: highlightColor ?? (isActive ? theme.background.withOpacity(0.8) : theme.background.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: theme.accentColor, width: 4) : Border.all(color: theme.gridColor.withOpacity(0.3), width: 1),
      ),
      child: Stack(children: [
        GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: 9,
          itemBuilder: (context, sqIdx) {
            String val = engine.board[subGridIdx][sqIdx];
            return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
              if (appState.isLocalPlay || appState.isBotPlay || engine.currentPlayer == appState.myPlayerSymbol) {
                if (engine.canMove(subGridIdx, sqIdx)) {
                  engine.makeMove(subGridIdx, sqIdx);
                  if (!appState.isLocalPlay && !appState.isBotPlay) Provider.of<NetworkManager>(context, listen: false).sendData({"type": "MOVE", "subGrid": subGridIdx, "square": sqIdx, "player": appState.myPlayerSymbol == "X" ? "X" : "O"});
                } else appState.setDebug("GO TO GRID ${engine.activeMiniGrid != null ? engine.activeMiniGrid! + 1 : 'ANY'}");
              } else appState.setDebug("WAIT FOR OPPONENT");
            }, child: Container(margin: const EdgeInsets.all(1), decoration: BoxDecoration(border: Border.all(color: theme.gridColor.withOpacity(0.2), width: 0.5)),
                child: Center(child: Text(val, style: TextStyle(color: (val == "X" ? theme.playerXColor : theme.playerOColor).withOpacity(isActive ? 1.0 : 0.4), fontSize: 20, fontWeight: FontWeight.w900)))));
          }),
        if (win != "" && appState.overlayMode == OverlayMode.bigSymbol) IgnorePointer(child: Center(child: Opacity(opacity: 0.5, child: Text(win, style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: win == "X" ? theme.playerXColor : theme.playerOColor))))),
      ]),
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final List<int> winningLine;
  final Color color;
  WinningLinePainter(this.winningLine, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.8)..strokeWidth = 12..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    double getX(int idx) => (idx % 3) * (size.width / 3) + (size.width / 6);
    double getY(int idx) => (idx ~/ 3) * (size.height / 3) + (size.height / 6);
    canvas.drawLine(Offset(getX(winningLine[0]), getY(winningLine[0])), Offset(getX(winningLine[2]), getY(winningLine[2])), paint);
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
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      int phase = (_controller.value * 3).floor();
      return GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 9,
        itemBuilder: (context, macroIdx) {
          bool isTarget = phase >= 1 && macroIdx == 2;
          return Container(decoration: BoxDecoration(color: isTarget ? widget.theme.accentColor.withOpacity(0.3) : Colors.white10, borderRadius: BorderRadius.circular(4)),
            child: GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: 9,
              itemBuilder: (context, miniIdx) {
                bool isMove = phase >= 1 && macroIdx == 4 && miniIdx == 2;
                return Center(child: isMove ? Text("X", style: TextStyle(color: widget.theme.playerXColor, fontWeight: FontWeight.bold, fontSize: 10)) : null);
              }));
        });
    });
  }
}