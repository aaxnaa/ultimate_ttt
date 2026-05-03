import 'package:flutter/material.dart';

class UltimateTTTEngine extends ChangeNotifier {
  // 9 sub-grids, each with 9 squares. [subGridIndex][squareIndex]
  List<List<String>> board = List.generate(9, (_) => List.generate(9, (_) => ""));
  
  // Track who won each sub-grid (X, O, or "")
  List<String> miniWins = List.generate(9, (_) => "");
  
  // Which sub-grid the current player MUST play in (0-8). 
  // If null, they have a "Free Move" anywhere.
  int? activeMiniGrid;
  
  String currentPlayer = "X";
  String? winner;

  // For Unanimous Draw Voting
  bool pendingDrawVote = false;
  int? tiedGridIndex;
  bool? myDrawVote;
  bool? opponentDrawVote;

  bool restartRequested = false;

  void setRestartRequested(bool requested) {
    restartRequested = requested;
    notifyListeners();
  }

  void makeMove(int subGridIndex, int squareIndex) {
    if (winner != null || pendingDrawVote) return;
    
    // Validate move: 
    // 1. Must be current player's target grid (unless free move)
    // 2. Square must be empty
    if (activeMiniGrid != null && subGridIndex != activeMiniGrid) return;
    if (board[subGridIndex][squareIndex] != "") return;

    // Apply move
    board[subGridIndex][squareIndex] = currentPlayer;

    // Check if this sub-grid was just won (if not already won)
    if (miniWins[subGridIndex] == "") {
      String subWin = _checkWin(board[subGridIndex]);
      if (subWin != "") {
        miniWins[subGridIndex] = subWin;
        // Check if the whole game is won
        winner = _checkWin(miniWins);
      } else if (_isGridFull(board[subGridIndex])) {
        // Tie detected in mini-grid
        miniWins[subGridIndex] = "T";
        pendingDrawVote = true;
        tiedGridIndex = subGridIndex;
        myDrawVote = null;
        opponentDrawVote = null;
      }
    }

    // Determine next active grid based on the squareIndex played
    int nextGrid = squareIndex;
    
    // Rule: If sent to a grid that is FULL, it's a Free Move.
    // (Note: Per user request, won grids are STILL playable if not full)
    if (_isGridFull(board[nextGrid])) {
      activeMiniGrid = null; // Free move
    } else {
      activeMiniGrid = nextGrid;
    }

    // Switch player
    currentPlayer = (currentPlayer == "X") ? "O" : "X";
    
    notifyListeners();
  }

  void castDrawVote(bool vote, bool isMe) {
    if (isMe) {
      myDrawVote = vote;
    } else {
      opponentDrawVote = vote;
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
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];
    for (var w in wins) {
      if (b[w[0]] != "" && b[w[0]] == b[w[1]] && b[w[0]] == b[w[2]]) {
        return b[w[0]];
      }
    }
    return "";
  }

  bool _isGridFull(List<String> b) {
    return !b.contains("");
  }

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
