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

  public function getBoard() : Array<Array<Hex>> {
    var b = new Array<Array<Hex>>();
    for (arr in board) {
      b.push(arr.copy());
    }
    return b;
  }

  /**
   * Ensures that the board is at least rows*cols large
   * Adds empty spots to bottom and right (i.e. 0,0 is considered top left)
   * rows and cols both have to be greater than 0. (throws otherwise)
   */

  public function ensureSize(rows : Int, cols : Int) : Void {
    if (rows <= 0 || cols <= 0) throw "Rows and Cols have to be > 0, got " + rows + ", " + cols;
    while (getHeight() < rows) {
      addRowBottom();
    }
    while (getWidth() < cols) {
      addColRight();
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
    for (arr in board) {
      arr.unshift(null);
    }
  }

  /** Adds an empty row (full of nulls) to the top of the board */

  public inline function addColRight() : Void {
    for (arr in board) {
      arr.push(null);
    }
  }

  /** Returns the Hex at the given row,col */

  public inline function get(row : Int, col : Int) : Hex {
    return board[row][col];
  }

  /** Returns the Hex at the given point */

  public inline function getAt(p : Point) : Hex {
    return board[p.row][p.col];
  }

  /** Puts a Hex at the given location. If there is already a hex there, overwrites.
   *  Returns h, for chaining? Idk.
   */

  public inline function set(row : Int, col : Int, h : Hex) : Hex {
    board[row][col] = h;
    return h;
  }

  /** Puts a Hex at the given location. If there is already a hex there, overwrites */

  public inline function setAt(p : Point, h : Hex) : Hex {
    board[p.row][p.col] = h;
    return h;
  }

  /** Removes the hex (if any) at row,col. Returns the removed hex, if any */

  public inline function remove(row : Int, col : Int) : Hex {
    var h = board[row][col];
    board[row][col] = null;
    return h;
  }

  /** Removes the hex (if any) at p. Returns the removed hex, if any */

  public inline function removeAt(p : Point) : Hex {
    var h = board[p.row][p.col];
    board[p.row][p.col] = null;
    return h;
  }

  /** Swaps the hexes at the given locations */

  public inline function swap(p1 : Point, p2 : Point) : Void {
    var h = get(p1.row, p1.col);
    var h2 = get(p2.row, p2.col);
    set(p1.row, p1.col, h2);
    set(p2.row, p2.col, h);
  }

  /** Swaps the hexes at the given locations. Moves each to the next location in the list.
   * Thus if given [p1,p2,p3,p4] which have [h1,h2,h3,h4], ending locations are [h4,h1,h2,h3]
   **/

  public inline function swapManyForward(locations : Array<Point>) : Void {
    if (locations.length > 1) {
      var l2 = locations.copy();
      l2.reverse();
      swapManyBackward(l2);
    }
  }

  /** Swaps the hexes at the given locations. Moves each to the previous location in the list.
   * Thus if given [p1,p2,p3,p4] which have [h1,h2,h3,h4], ending locations are [h2,h3,h4,h1]
   **/

  public inline function swapManyBackward(locations : Array<Point>) : Void {
    if (locations.length > 1) {
      var iter1 : Iterator<Point> = locations.iterator();
      var iter2 : Iterator<Point> = locations.iterator();
      iter2.next();

      while (iter2.hasNext()) {
        swap(iter1.next(), iter2.next());
      }
    }
  }

  /** Shifts/Rotates the hexes in this board by the given deltas.
   * Positive values shift down and right, respectively, and negatives the opposite
   * Doesn't change board size; hexes that would be pushed off the board wrap as necessary
   **/

  public function shift(dRow : Int, dCol : Int) : Void {
    if (dCol > 0) {
      for (i in 0...dCol) {
        Util.rotateForward(board);
      }
    } else if (dCol < 0) {
      for (i in 0...(-dCol)) {
        Util.rotateBackward(board);
      }
    }
    if (dRow > 0) {
      for (i in 0...dRow) {
        for (r in 0...getHeight()) {
          Util.rotateForward(board[r]);
        }
      }
    } else if (dRow < 0) {
      for (i in 0...(-dRow)) {
        for (r in 0...getHeight()) {
          Util.rotateBackward(board[r]);
        }
      }
    }
  }

}
