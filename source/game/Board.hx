package game;

class Board {

  private var board : Array<Array<Hex>>;

  /** Number of hexes currently in the board */
  public var size(default, null) : Int;

  /** Structural and swap mod count.
   * Notably, row and col additions, shifts, and swaps cause modCount increase, but sets and removes don't.
   * This allows for setting/removing during iteration.
   * Size changes and Shifts not allowed because they make the internal count of the iterator invalid
   * Swaps not allowed because they may lead to double-iterating over the same element
   **/
  public var modCount(default,null) : Int;

  public function new() {
    board = new Array<Array<Hex>>();
    size = 0;
    modCount = 0;
  }

  public inline function getHeight() : Int {
    return board.length;
  }

  public inline function getWidth() : Int {
    if (board.length == 0) return 0;
    else return board[0].length;
  }

  public inline function isInBounds(p : Point) : Bool {
    return p.row >= 0 && p.col >= 0 && p.row < getHeight() && p.col < getWidth();
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

  /** Returns an iterator over the hexes in this board. Goes left to right and top to bottom */
  public function iterator() : Iterator<Hex> {
    return new BoardIterator(this);
  }

  /**
   * Ensures that the board is at least rows*cols large
   * Adds empty spots to bottom and right (i.e. 0,0 is considered top left)
   * rows and cols both have to be greater than 0. (throws otherwise)
   * Returns a reference to this board, so it can be used in construction.
   */

  public function ensureSize(rows : Int, cols : Int) : Board {
    if (rows <= 0 || cols <= 0) throw "Rows and Cols have to be > 0, got " + rows + ", " + cols;
    while (getHeight() < rows) {
      addRowBottom();
    }
    while (getWidth() < cols) {
      addColRight();
    }
    return this;
  }

  /** Adds an empty row (full of nulls) to the top of the board */

  public inline function addRowTop() : Void {
    board.unshift(Util.emptyArray(Hex, getWidth()));
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the board */

  public inline function addRowBottom() : Void {
    board.push(Util.emptyArray(Hex, getWidth()));
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the board */

  public inline function addColLeft() : Void {
    for (arr in board) {
      arr.unshift(null);
    }
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the board */

  public inline function addColRight() : Void {
    for (arr in board) {
      arr.push(null);
    }
    modCount++;
  }

  /** Returns the Hex at the given row,col */

  public inline function get(row : Int, col : Int) : Hex {
    return board[row][col];
  }

  /** Returns the Hex at the given point */

  public inline function getAt(p : Point) : Hex {
    return get(p.row, p.col);
  }

  /** Puts a Hex at the given location. If there is already a hex there, overwrites.
   *  Returns h, for chaining? Idk.
   */

  public function set(row : Int, col : Int, h : Hex) : Hex {
    if (board[row][col] != null) {
      board[row][col].position = Point.get(-1,-1);
      size--;
    }
    board[row][col] = h;
    if (h != null) {
      size++;
      h.position = Point.get(row, col);
    }
    return h;
  }

  /** Puts a Hex at the given location. If there is already a hex there, overwrites */

  public inline function setAt(p : Point, h : Hex) : Hex {
    return set(p.row, p.col, h);
  }

  /** Removes the hex (if any) at row,col. Returns the removed hex, if any */

  public inline function remove(row : Int, col : Int) : Hex {
    var h = board[row][col];
    if (h != null) {
      h.position = Point.get(-1,-1);
      size--;
    }
    board[row][col] = null;
    return h;
  }

  /** Removes the hex (if any) at p. Returns the removed hex, if any */

  public inline function removeAt(p : Point) : Hex {
    return remove(p.row, p.col);
  }

  /** Swaps the hexes at the given locations */

  public inline function swap(p1 : Point, p2 : Point) : Void {
    var h = get(p1.row, p1.col);
    var h2 = get(p2.row, p2.col);
    set(p1.row, p1.col, h2);
    set(p2.row, p2.col, h);

    if (h2 != null) h2.position = p1;
    if (h != null) h.position = p2;

    modCount++;
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
      modCount++;
    } else if (dCol < 0) {
      for (i in 0...(-dCol)) {
        Util.rotateBackward(board);
      }
      modCount++;
    }
    if (dRow > 0) {
      for (i in 0...dRow) {
        for (r in 0...getHeight()) {
          Util.rotateForward(board[r]);
        }
      }
      modCount++;
    } else if (dRow < 0) {
      for (i in 0...(-dRow)) {
        for (r in 0...getHeight()) {
          Util.rotateBackward(board[r]);
        }
      }
      modCount++;
    }

    if (dCol != 0 && dRow != 0) {
      var delta = Point.get(dRow, dCol);
      var hex : Hex = null;
      for(hex in this) {
        hex.position = Point.get(Util.mod(hex.position.row + delta.row, getHeight()),Util.mod(hex.position.col + delta.col, getWidth()));
      }
    }
  }

}

private class BoardIterator {

  private var b : Board;
  private var expectedModCount : Int;
  private var p : Point;
  private var count : Int;

  public function new(b : Board) {
    this.b = b;
    expectedModCount = b.modCount;
    p = Point.get(0,0);
    count = 0;
  }

  public function next() : Hex {
    var h : Hex = null;
    while((h = b.getAt(p)) == null){
      incPosition();
    }
    incPosition();
    count++;
    return h;
  }

  private function incPosition() : Void {
    if(p.col < b.getWidth() - 1) {
      p = Point.get(p.row, p.col+1);
    } else if (p.row < b.getHeight() - 1) {
      p = Point.get(p.row+1, 0);
    }
  }

  public inline function hasNext() : Bool {
    if (expectedModCount != b.modCount) throw "ConcurrentModification: expected " + expectedModCount + " but got " + b.modCount;
    return count < b.size;
  }

}