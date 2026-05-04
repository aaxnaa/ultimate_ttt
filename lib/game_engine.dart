import 'package:flutter/material.dart';

class UltimateTTTEngine extends ChangeNotifier {
  List<List<String>> board = List.generate(9, (_) => List.generate(9, (_) => ""));
  List<String> miniWins = List.generate(9, (_) => "");
  int? activeMiniGrid;
  String currentPlayer = "X";
  String? winner;
  List<int>? winningLine;

  bool pendingDrawVote = false;
  int? tiedGridIndex;
  bool? myDrawVote;
  bool? opponentDrawVote;
  bool restartRequested = false;

  void setRestartRequested(bool requested) {
    restartRequested = requested;
    notifyListeners();
  }

  bool canMove(int subGridIndex, int squareIndex) {
    if (winner != null || pendingDrawVote) return false;
    if (activeMiniGrid != null && subGridIndex != activeMiniGrid) return false;
    if (board[subGridIndex][squareIndex] != "") return false;
    return true;
  }

  // Standard move for local clicks
  void makeMove(int subGridIndex, int squareIndex) {
    _applyMoveInternal(subGridIndex, squareIndex);
  }

  // Forces a move from a remote player to ensure synchronization even if states slightly differ
  void forceRemoteMove(int subGridIndex, int squareIndex, String player) {
    // Sync current player just in case of lag
    currentPlayer = player; 
    _applyMoveInternal(subGridIndex, squareIndex);
  }

  void _applyMoveInternal(int subGridIndex, int squareIndex) {
    if (winner != null) return;
    if (board[subGridIndex][squareIndex] != "") return;

    board[subGridIndex][squareIndex] = currentPlayer;

    if (miniWins[subGridIndex] == "") {
      String subWin = _checkWin(board[subGridIndex]);
      if (subWin != "") {
        miniWins[subGridIndex] = subWin;
        _checkUltimateWin();
      } else if (_isGridFull(board[subGridIndex])) {
        miniWins[subGridIndex] = "T";
        pendingDrawVote = true;
        tiedGridIndex = subGridIndex;
        myDrawVote = null;
        opponentDrawVote = null;
      }
    }

    if (winner == null) {
      int nextGrid = squareIndex;
      // V2.4 Rule: Free move only if target is 100% full
      if (_isGridFull(board[nextGrid])) {
         activeMiniGrid = null;
      } else {
        activeMiniGrid = nextGrid;
      }
      currentPlayer = (currentPlayer == "X") ? "O" : "X";
    }
    
    notifyListeners();
  }

  void _checkUltimateWin() {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var w in wins) {
      if (miniWins[w[0]] != "" && miniWins[w[0]] != "T" && miniWins[w[0]] == miniWins[w[1]] && miniWins[w[0]] == miniWins[w[2]]) {
        winner = miniWins[w[0]];
        winningLine = w;
        return;
      }
    }
    if (!miniWins.contains("")) {
      winner = "DRAW";
    }
  }

  void castDrawVote(bool vote, bool isMe, bool isLocal) {
    if (isLocal) {
      myDrawVote = vote;
      opponentDrawVote = vote;
    } else {
      if (isMe) myDrawVote = vote; else opponentDrawVote = vote;
    }

    if (myDrawVote != null && opponentDrawVote != null) {
      if (myDrawVote! && opponentDrawVote!) {
        miniWins[tiedGridIndex!] = "T";
        _checkUltimateWin();
      } else {
        miniWins[tiedGridIndex!] = "";
      }
      pendingDrawVote = false;
      tiedGridIndex = null;
    }
    notifyListeners();
  }

  void syncState({
    required List<List<String>> newBoard,
    required List<String> newMiniWins,
    required int? newActiveMiniGrid,
    required String newCurrentPlayer,
  }) {
    board = newBoard;
    miniWins = newMiniWins;
    activeMiniGrid = newActiveMiniGrid;
    currentPlayer = newCurrentPlayer;
    notifyListeners();
  }

  String _checkWin(List<String> b) {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var w in wins) {
      if (b[w[0]] != "" && b[w[0]] == b[w[1]] && b[w[0]] == b[w[2]]) return b[w[0]];
    }
    return "";
  }

  bool _isGridFull(List<String> b) => !b.contains("");

  void reset() {
    board = List.generate(9, (_) => List.generate(9, (_) => ""));
    miniWins = List.generate(9, (_) => "");
    activeMiniGrid = null;
    currentPlayer = "X";
    winner = null;
    winningLine = null;
    pendingDrawVote = false;
    tiedGridIndex = null;
    myDrawVote = null;
    opponentDrawVote = null;
    restartRequested = false;
    notifyListeners();
  }
}
