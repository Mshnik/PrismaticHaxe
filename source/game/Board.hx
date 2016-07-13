package game;
class Board {

  private var board : Array<Array<Hex>>;

  public function new() {
    board = new Array<Array<Hex>>();
  }

  public inline function getHeight() : Int {
    return board.length;
  }

  public inline function getWidth() : Int {
    if (board.length == 0) return 0;
    else return board[0].length;
  }

  /** Returns a copy of the underlying 2D array representing the board.
   * The arrays are all new instances, but the hexes stored are the same references as in the
   * true board.
   */
  public function get() : Array<Array<Hex>> {
    var b = new Array<Array<Hex>>();
    for(arr in board) {
      b.push(arr.copy());
    }
    return b;
  }

  /**
   * Ensures that the board is at least rows*cols large
   * Adds empty spots to bottom and right (i.e. 0,0 is considered top left)
   */
  public function ensureSize(rows : Int, cols : Int) : Void {
    for(arr in board) {
      while (arr.length < cols) {
        arr.push(null);
      }
    }
    while (getHeight() < rows) {
      board.push(Util.emptyArray(Hex, cols));
    }
  }

  /** Adds an empty row (full of nulls) to the top of the board */
  public inline function addRowTop() : Void {
    board.unshift(Util.emptyArray(Hex, getWidth()));
  }

  /** Adds an empty row (full of nulls) to the top of the board */
  public inline function addRowBottom() : Void {
    board.push(Util.emptyArray(Hex, getWidth()));
  }

  /** Adds an empty row (full of nulls) to the top of the board */
  public inline function addColLeft() : Void {
    for(arr in board) {
      arr.unshift(null);
    }
  }

  /** Adds an empty row (full of nulls) to the top of the board */
  public inline function addColRight() : Void {
    for(arr in board) {
      arr.push(null);
    }
  }

  /** Shifts/Rotates the hexes in this board by the given deltas.
   * Positive values shift down and right, respectively, and negatives the opposite
   **/
  public function shift(dRow : Int, dCol : Int) : Void {
    if (dCol > 0) {
      for(i in 0...dCol) {
        Util.rotateForward(board);
      }
    } else if (dCol < 0) {
      for (i in 0...(-dCol)) {
        Util.rotateBackward(board);
      }
    }
    if (dRow > 0) {
      for(i in 0...dRow) {
        for(r in 0...getHeight()) {
          Util.rotateForward(board[r]);
        }
      }
    } else if (dRow < 0) {
      for(i in 0...(-dRow)) {
        for(r in 0...getHeight()) {
          Util.rotateBackward(board[r]);
        }
      }
    }
  }

}
