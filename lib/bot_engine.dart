import 'dart:math';
import 'game_engine.dart';

enum BotDifficulty { easy, medium, hard, extraHard }

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
    int delay = (difficulty == BotDifficulty.extraHard) ? 1200 : 800;
    await Future.delayed(Duration(milliseconds: delay + _random.nextInt(500)));
    
    if (engine.winner != null) {
      isThinking = false;
      return;
    }

    int targetGrid = engine.activeMiniGrid ?? _getBestGridForBot();
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
      case BotDifficulty.extraHard:
        chosenSquare = _getExtraHardMove(targetGrid);
        break;
    }

    if (chosenSquare != -1) {
      engine.makeMove(targetGrid, chosenSquare);
    }
    
    isThinking = false;
  }

  int _getBestGridForBot() {
    // If it's a free move, pick the best grid
    if (difficulty == BotDifficulty.extraHard || difficulty == BotDifficulty.hard) {
      // Prioritize grids where we can win immediately
      for (int i = 0; i < 9; i++) {
        if (engine.miniWins[i] == "" && engine.board[i].contains("")) {
           if (_findWinningMove(i, botSymbol) != -1) return i;
        }
      }
      // Or block opponent from winning a grid
      String opponent = botSymbol == "X" ? "O" : "X";
      for (int i = 0; i < 9; i++) {
        if (engine.miniWins[i] == "" && engine.board[i].contains("")) {
           if (_findWinningMove(i, opponent) != -1) return i;
        }
      }
    }
    return _getRandomValidGrid();
  }

  int _getRandomValidGrid() {
    List<int> validGrids = [];
    for (int i = 0; i < 9; i++) {
      if (engine.miniWins[i] == "" && engine.board[i].contains("")) {
        validGrids.add(i);
      }
    }
    if (validGrids.isEmpty) return 0;
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
    int winningMove = _findWinningMove(gridIdx, botSymbol);
    if (winningMove != -1) return winningMove;

    String opponentSymbol = botSymbol == "X" ? "O" : "X";
    int blockingMove = _findWinningMove(gridIdx, opponentSymbol);
    if (blockingMove != -1) return blockingMove;

    return _getRandomValidSquare(gridIdx);
  }

  int _getHardMove(int gridIdx) {
    int winningMove = _findWinningMove(gridIdx, botSymbol);
    if (winningMove != -1) return winningMove;

    String opponentSymbol = botSymbol == "X" ? "O" : "X";
    int blockingMove = _findWinningMove(gridIdx, opponentSymbol);
    if (blockingMove != -1) return blockingMove;

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

  int _getExtraHardMove(int gridIdx) {
    // Minimax with depth 5 for the current grid, but considers macro board
    List<int> emptySquares = [];
    for (int i = 0; i < 9; i++) {
      if (engine.board[gridIdx][i] == "") emptySquares.add(i);
    }

    int bestScore = -10000;
    int bestMove = emptySquares.isNotEmpty ? emptySquares[0] : -1;

    for (int move in emptySquares) {
      // 1. Check if this move wins the grid
      List<String> b = List.from(engine.board[gridIdx]);
      b[move] = botSymbol;
      bool winsGrid = _checkSingleWin(b) == botSymbol;
      
      int score = 0;
      if (winsGrid) {
        score += 50;
        // Does winning this grid win the WHOLE game?
        List<String> mw = List.from(engine.miniWins);
        mw[gridIdx] = botSymbol;
        if (_checkSingleWin(mw) == botSymbol) score += 1000;
      }

      // 2. Strategic Positioning
      if (move == 4) score += 5; // Center
      if ([0, 2, 6, 8].contains(move)) score += 2; // Corners

      // 3. Opponent's next state
      if (engine.miniWins[move] != "") {
        // We sent them to a won grid -> FREE MOVE. Very bad.
        score -= 30;
      } else if (!engine.board[move].contains("")) {
        // Sent to full grid -> FREE MOVE. Very bad.
        score -= 30;
      } else {
        // Where are we sending them?
        String opponent = botSymbol == "X" ? "O" : "X";
        int oppWinThere = _findWinningMove(move, opponent);
        if (oppWinThere != -1) {
          score -= 40; // They can win that grid immediately
        }
        
        // Block them if they are about to win the big board
        List<String> mwOpp = List.from(engine.miniWins);
        mwOpp[move] = opponent;
        if (_checkSingleWin(mwOpp) == opponent) {
           score -= 100; // Extremely bad: sends them to a grid they can win to win the game
        }
      }

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
    if (moveSquare == 4) score += 3;
    if ([0, 2, 6, 8].contains(moveSquare)) score += 1;

    if (engine.miniWins[moveSquare] == "") {
       int opponentWinThere = _findWinningMove(moveSquare, opponentSymbol);
       if (opponentWinThere != -1) {
         score -= 10;
       }
    }
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
