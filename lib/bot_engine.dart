import 'dart:math';
import 'game_engine.dart';

enum BotDifficulty { easy, medium, hard }

class BotEngine {
  final UltimateTTTEngine engine;
  final BotDifficulty difficulty;
  final String botSymbol;
  bool isThinking = false;
  final Random _random = Random();

  BotEngine({required this.engine, required this.difficulty, required this.botSymbol});

  Future<void> makeMove() async {
    if (engine.winner != null || engine.currentPlayer != botSymbol || isThinking) return;
    
    isThinking = true;
    
    // Artificial delay to make it feel like it's thinking
    await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(800)));
    
    if (engine.winner != null) {
      isThinking = false;
      return;
    }

    int targetGrid = engine.activeMiniGrid ?? _getRandomValidGrid();
    int chosenSquare = -1;

    switch (difficulty) {
      case BotDifficulty.easy:
        chosenSquare = _getRandomValidSquare(targetGrid);
        break;
      case BotDifficulty.medium:
        chosenSquare = _getMediumMove(targetGrid);
        break;
      case BotDifficulty.hard:
        chosenSquare = _getHardMove(targetGrid);
        break;
    }

    if (chosenSquare != -1) {
      engine.makeMove(targetGrid, chosenSquare);
    }
    
    isThinking = false;
  }

  int _getRandomValidGrid() {
    List<int> validGrids = [];
    for (int i = 0; i < 9; i++) {
      if (engine.miniWins[i] == "" && engine.board[i].contains("")) {
        validGrids.add(i);
      }
    }
    if (validGrids.isEmpty) return 0; // Fallback
    return validGrids[_random.nextInt(validGrids.length)];
  }

  int _getRandomValidSquare(int gridIdx) {
    List<int> emptySquares = [];
    for (int i = 0; i < 9; i++) {
      if (engine.board[gridIdx][i] == "") emptySquares.add(i);
    }
    if (emptySquares.isEmpty) return -1;
    return emptySquares[_random.nextInt(emptySquares.length)];
  }

  int _getMediumMove(int gridIdx) {
    // 1. Try to win the current grid
    int winningMove = _findWinningMove(gridIdx, botSymbol);
    if (winningMove != -1) return winningMove;

    // 2. Try to block the opponent from winning the current grid
    String opponentSymbol = botSymbol == "X" ? "O" : "X";
    int blockingMove = _findWinningMove(gridIdx, opponentSymbol);
    if (blockingMove != -1) return blockingMove;

    // 3. Otherwise, random
    return _getRandomValidSquare(gridIdx);
  }

  int _getHardMove(int gridIdx) {
    // Basic Minimax for the current active grid
    // For ultimate TTT, full board minimax is too slow. 
    // We prioritize winning the local grid, blocking, and NOT sending the opponent to a grid where they can win.
    
    // First, check immediate win/block
    int winningMove = _findWinningMove(gridIdx, botSymbol);
    if (winningMove != -1) return winningMove;

    String opponentSymbol = botSymbol == "X" ? "O" : "X";
    int blockingMove = _findWinningMove(gridIdx, opponentSymbol);
    if (blockingMove != -1) return blockingMove;

    // If no immediate threat, evaluate all possible moves in this grid
    List<int> emptySquares = [];
    for (int i = 0; i < 9; i++) {
      if (engine.board[gridIdx][i] == "") emptySquares.add(i);
    }

    int bestScore = -1000;
    int bestMove = emptySquares.isNotEmpty ? emptySquares[0] : -1;

    for (int move in emptySquares) {
      int score = _evaluateMove(gridIdx, move, opponentSymbol);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _findWinningMove(int gridIdx, String symbol) {
    List<String> b = List.from(engine.board[gridIdx]);
    for (int i = 0; i < 9; i++) {
      if (b[i] == "") {
        b[i] = symbol;
        if (_checkSingleWin(b) == symbol) return i;
        b[i] = "";
      }
    }
    return -1;
  }

  int _evaluateMove(int currentGrid, int moveSquare, String opponentSymbol) {
    int score = 0;
    
    // Center is good
    if (moveSquare == 4) score += 3;
    // Corners are okay
    if ([0, 2, 6, 8].contains(moveSquare)) score += 1;

    // BAD: Does this move send the opponent to a grid where they have a winning move?
    if (engine.miniWins[moveSquare] == "") {
       int opponentWinThere = _findWinningMove(moveSquare, opponentSymbol);
       if (opponentWinThere != -1) {
         score -= 10; // Avoid sending them to a grid they can win
       }
    }

    // VERY BAD: Does this move send the opponent to a 100% full grid, giving them a free move?
    if (!engine.board[moveSquare].contains("")) {
      score -= 15;
    }

    return score;
  }

  String _checkSingleWin(List<String> b) {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var w in wins) {
      if (b[w[0]] != "" && b[w[0]] == b[w[1]] && b[w[0]] == b[w[2]]) return b[w[0]];
    }
    return "";
  }
}
