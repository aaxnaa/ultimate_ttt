import 'package:flutter/material.dart';

class UltimateTTTEngine extends ChangeNotifier {
  List<List<String>> board = List.generate(9, (_) => List.generate(9, (_) => ""));
  List<String> miniWins = List.generate(9, (_) => "");
  int? activeMiniGrid;
  String currentPlayer = "X";
  String? winner;

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

  void makeMove(int subGridIndex, int squareIndex) {
    if (!canMove(subGridIndex, squareIndex)) return;

    board[subGridIndex][squareIndex] = currentPlayer;

    if (miniWins[subGridIndex] == "") {
      String subWin = _checkWin(board[subGridIndex]);
      if (subWin != "") {
        miniWins[subGridIndex] = subWin;
        winner = _checkWin(miniWins);
      } else if (_isGridFull(board[subGridIndex])) {
        miniWins[subGridIndex] = "T";
        pendingDrawVote = true;
        tiedGridIndex = subGridIndex;
        myDrawVote = null;
        opponentDrawVote = null;
      }
    }

    int nextGrid = squareIndex;
    if (_isGridFull(board[nextGrid])) {
      activeMiniGrid = null;
    } else {
      activeMiniGrid = nextGrid;
    }

    currentPlayer = (currentPlayer == "X") ? "O" : "X";
    notifyListeners();
  }

  void castDrawVote(bool vote, bool isMe, bool isLocal) {
    if (isLocal) {
      // In local play, one click decides for both to avoid freezing
      myDrawVote = vote;
      opponentDrawVote = vote;
    } else {
      if (isMe) myDrawVote = vote; else opponentDrawVote = vote;
    }

    if (myDrawVote != null && opponentDrawVote != null) {
      if (myDrawVote! && opponentDrawVote!) {
        winner = "DRAW";
      }
      pendingDrawVote = false;
      tiedGridIndex = null;
    }
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
    pendingDrawVote = false;
    tiedGridIndex = null;
    myDrawVote = null;
    opponentDrawVote = null;
    restartRequested = false;
    notifyListeners();
  }
}
