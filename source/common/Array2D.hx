package common;

/**
 * Subclasses should write an iterator() method. Would put it here, but the typing system
 * seems a bit broken.
 */
@:generic class Array2D<T : Positionable> {

  /** The values represented in this 2D array */
  private var vals : Array<Array<T>>;

  /** Number of Ts currently in the Array2D */
  public var size(default, null) : Int;

  /** Structural and swap mod count.
   * Notably, row and col additions, shifts, and swaps cause modCount increase, but sets and removes don't.
   * This allows for setting/removing during iteration.
   * Size changes and Shifts not allowed because they make the internal count of the iterator invalid
   * Swaps not allowed because they may lead to double-iterating over the same element
   **/
  public var modCount(default, null) : Int;

  public function new(rows : Int = 0, cols : Int = 0) {
    vals = new Array<Array<T>>();
    size = 0;
    modCount = 0;
    ensureSize(rows, cols);
  }

  public function toString() : String {
    var s = new StringBuf();
    s.add("[");
    if (vals.length > 0) {
      s.add("\n");
    }
    for(arr in vals) {
      s.add("\t");
      s.add(arr);
      s.add("\n");
    }
    s.add("]");
    return s.toString();
  }

  public inline function getHeight() : Int {
    return vals.length;
  }

  public inline function getWidth() : Int {
    if (vals.length == 0) return 0;
    else return vals[0].length;
  }

  public inline function isInBounds(p : Point) : Bool {
    return p.row >= 0 && p.col >= 0 && p.row < getHeight() && p.col < getWidth();
  }

  /** Returns a copy of the underlying 2D array representing the Array2D.
   * The arrays are all Source instances, but the Ts stored are the same references as in the
   * true Array2D.
   */

  public function asNestedArrays() : Array<Array<T>> {
    var b = new Array<Array<T>>();
    for (arr in vals) {
      b.push(arr.copy());
    }
    return b;
  }

  public function iterator() : Iterator<T> {
    return new Array2DIterator<T>(this);
  }

  /**
   * Ensures that the Array2D is at least rows*cols large
   * Adds empty spots to bottom and right (i.e. 0,0 is considered top left)
   * rows and cols both have to be greater than 0. (throws otherwise)
   * Returns a reference to this Array2D, so it can be used in construction.
   */

  public function ensureSize(rows : Int, cols : Int) : Array2D<T> {
    if (rows < 0 || cols < 0) throw "Rows and Cols have to be >= 0, got " + rows + ", " + cols;
    while (getHeight() < rows) {
      addRowBottom();
    }
    while (getWidth() < cols) {
      addColRight();
    }
    return this;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D */

  public function addRowTop() : Void {
    var arr : Array<T> = [];
    for (i in 0...getWidth()) {
      arr.push(null);
    }
    vals.unshift(arr);
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D */

  public function addRowBottom() : Void {
    var arr : Array<T> = [];
    for (i in 0...getWidth()) {
      arr.push(null);
    }
    vals.push(arr);
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D */

  public function addColLeft() : Void {
    for (arr in vals) {
      arr.unshift(null);
    }
    modCount++;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D */

  public function addColRight() : Void {
    for (arr in vals) {
      arr.push(null);
    }
    modCount++;
  }

  /** Returns the T at the given row,col */

  public inline function get(row : Int, col : Int) : T {
    return vals[row][col];
  }

  /** Returns the T at the given point */

  public inline function getAt(p : Point) : T {
    return get(p.row, p.col);
  }

  /** Puts a T at the given location. If there is already a t there, overwrites.
   *  Returns h, for chaining? Idk.
   */
  public function set(row : Int, col : Int, h : T) : T {
    if (vals[row][col] != null) {
      vals[row][col].position = Point.get(-1, -1);
      size--;
    }
    vals[row][col] = h;
    if (h != null) {
      size++;
      h.position = Point.get(row, col);
    }
    return h;
  }

  /** Puts a T at the given location. If there is already a t there, overwrites */

  public inline function setAt(p : Point, h : T) : T {
    return set(p.row, p.col, h);
  }

  /** Removes the t (if any) at row,col. Returns the removed t, if any */

  public function remove(row : Int, col : Int) : T {
    var h : T = vals[row][col];
    if (h != null) {
      h.position = Point.get(-1, -1);
      size--;
    }
    vals[row][col] = null;
    return h;
  }

  /** Removes the t (if any) at p. Returns the removed t, if any */

  public inline function removeAt(p : Point) : T {
    return remove(p.row, p.col);
  }

  /** Swaps the Ts at the given locations */

  public function swap(p1 : Point, p2 : Point) : Void {
    var h = get(p1.row, p1.col);
    var h2 = get(p2.row, p2.col);
    set(p1.row, p1.col, h2);
    set(p2.row, p2.col, h);

    if (h2 != null) h2.position = p1;
    if (h != null) h.position = p2;

    modCount++;
  }

  /** Swaps the Ts at the given locations. Moves each to the next location in the list.
   * Thus if given [p1,p2,p3,p4] which have [h1,h2,h3,h4], ending locations are [h4,h1,h2,h3]
   **/

  public inline function swapManyForward(locations : Array<Point>) : Void {
    if (locations.length > 1) {
      var l2 = locations.copy();
      l2.reverse();
      swapManyBackward(l2);
    }
  }

  /** Swaps the Ts at the given locations. Moves each to the previous location in the list.
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

  /** Shifts/Rotates the Ts in this Array2D by the given deltas.
   * Positive values shift down and right, respectively, and negatives the opposite
   * Doesn't change Array2D size; Ts that would be pushed off the Array2D wrap as necessary
   **/

  public function shift(dRow : Int, dCol : Int) : Void {
    if (dCol > 0) {
      for (i in 0...dCol) {
        Util.rotateForward(vals);
      }
      modCount++;
    } else if (dCol < 0) {
      for (i in 0...(-dCol)) {
        Util.rotateBackward(vals);
      }
      modCount++;
    }
    if (dRow > 0) {
      for (i in 0...dRow) {
        for (r in 0...getHeight()) {
          Util.rotateForward(vals[r]);
        }
      }
      modCount++;
    } else if (dRow < 0) {
      for (i in 0...(-dRow)) {
        for (r in 0...getHeight()) {
          Util.rotateBackward(vals[r]);
        }
      }
      modCount++;
    }

    if (dCol != 0 && dRow != 0) {
      var delta = Point.get(dRow, dCol);
      var iter = new Array2DIterator<T>(this);
      while (iter.hasNext()) {
        var t : T = iter.next();
        t.position = Point.get(Util.mod(t.position.row + delta.row, getHeight()), Util.mod(t.position.col + delta.col, getWidth()));
      }
    }
  }

  /**
   * Fills this Array2D with the given T. Calls elmCreator for each position
   * so instances are unique to each slot
   * Returns a reference to this, for chaining.
   **/
  public function fillWith(elmCreator : Void->T) : Array2D<T> {
    for (r in 0...getHeight()) {
      for (c in 0...getWidth()) {
        set(r,c,elmCreator());
      }
    }
    return this;
  }
}

@:generic class Array2DIterator<T : Positionable> {

  private var b : Array2D<T>;
  private var expectedModCount : Int;
  private var p : Point;
  private var count : Int;

  public function new(b : Array2D<T>) {
    this.b = b;
    expectedModCount = b.modCount;
    p = Point.get(0, 0);
    count = 0;
  }

  public function next() : T {
    var h : T = null;
    while ((h = b.getAt(p)) == null) {
      incPosition();
    }
    incPosition();
    count++;
    return h;
  }

  private function incPosition() : Void {
    if (p.col < b.getWidth() - 1) {
      p = Point.get(p.row, p.col + 1);
    } else if (p.row < b.getHeight() - 1) {
      p = Point.get(p.row + 1, 0);
    }
  }

  public inline function hasNext() : Bool {
    if (expectedModCount != b.modCount) throw "ConcurrentModification: expected " + expectedModCount + " but got " + b.modCount;
    return count < b.size;
  }

}
