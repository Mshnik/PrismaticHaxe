package common;

using common.CollectionExtender;
using common.IntExtender;

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

  public inline function isInBounds(row : Int, col : Int) : Bool {
    return row >= 0 && col >= 0 && row < getHeight() && col < getWidth();
  }

  public inline function isPointInBounds(p : Point) : Bool {
    return isInBounds(p.row, p.col);
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

  /** Adds an empty row (full of nulls) to the top of the Array2D.
   * Returns this.
  **/
  public function addRowTop() : Array2D<T> {
    var arr : Array<T> = [];
    for (i in 0...getWidth()) {
      arr.push(null);
    }
    vals.unshift(arr);
    modCount++;
    return this;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D.
   * Returns this.
  **/
  public function addRowBottom() : Array2D<T> {
    var arr : Array<T> = [];
    for (i in 0...getWidth()) {
      arr.push(null);
    }
    vals.push(arr);
    modCount++;
    return this;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D
  * Returns this.
  **/
  public function addColLeft() : Array2D<T> {
    for (arr in vals) {
      arr.unshift(null);
    }
    modCount++;
    return this;
  }

  /** Adds an empty row (full of nulls) to the top of the Array2D
   * Returns this.
   **/
  public function addColRight() : Array2D<T> {
    for (arr in vals) {
      arr.push(null);
    }
    modCount++;
    return this;
  }

  /** Returns the T at the given row,col. If safe, returns null if OOB */
  public function get(row : Int, col : Int, safe : Bool = false) : T {
    if (safe && ! isInBounds(row, col)) {
      return null;
    } else {
      return vals[row][col];
    }
  }

  /** Returns the T at the given point */
  public function getAt(p : Point, safe : Bool = false) : T {
    return get(p.row, p.col, safe);
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

  /** Swaps the Ts at the given locations, returns this. */

  public function swap(p1 : Point, p2 : Point) : Array2D<T> {
    var h = get(p1.row, p1.col);
    var h2 = get(p2.row, p2.col);
    set(p1.row, p1.col, h2);
    set(p2.row, p2.col, h);

    if (h2 != null) h2.position = p1;
    if (h != null) h.position = p2;

    modCount++;
    return this;
  }

  /** Swaps the Ts at the given locations. Moves each to the next location in the list.
   * Thus if given [p1,p2,p3,p4] which have [h1,h2,h3,h4], ending locations are [h4,h1,h2,h3]
   * Returns this.
   **/

  public function swapManyForward(locations : Array<Point>) : Array2D<T> {
    if (locations.length > 1) {
      var l2 = locations.copy();
      l2.reverse();
      swapManyBackward(l2);
    }
    return this;
  }

  /** Swaps the Ts at the given locations. Moves each to the previous location in the list.
   * Thus if given [p1,p2,p3,p4] which have [h1,h2,h3,h4], ending locations are [h2,h3,h4,h1].
   * Filters OOB locations before swapping any.
   * Returns this.
   **/
  public function swapManyBackward(locations : Array<Point>) : Array2D<T> {
    locations = locations.filter(isPointInBounds);
    if (locations.length > 1) {
      var iter1 : Iterator<Point> = locations.iterator();
      var iter2 : Iterator<Point> = locations.iterator();
      iter2.next();

      while (iter2.hasNext()) {
        swap(iter1.next(), iter2.next());
      }
    }
    return this;
  }

  /** Shifts/Rotates the Ts in this Array2D by the given deltas.
   * Positive values shift down and right, respectively, and negatives the opposite
   * Doesn't change Array2D size; Ts that would be pushed off the Array2D wrap as necessary.
   * Returns this.
   **/

  public function shift(dRow : Int, dCol : Int) : Array2D<T> {
    if (dCol > 0) {
      for (i in 0...dCol) {
        vals.rotateForward();
      }
      modCount++;
    } else if (dCol < 0) {
      for (i in 0...(-dCol)) {
        vals.rotateBackward();
      }
      modCount++;
    }
    if (dRow > 0) {
      for (i in 0...dRow) {
        for (r in 0...getHeight()) {
          vals[r].rotateForward();
        }
      }
      modCount++;
    } else if (dRow < 0) {
      for (i in 0...(-dRow)) {
        for (r in 0...getHeight()) {
          vals[r].rotateBackward();
        }
      }
      modCount++;
    }

    if (dCol != 0 && dRow != 0) {
      var delta = Point.get(dRow, dCol);
      var iter = new Array2DIterator<T>(this);
      while (iter.hasNext()) {
        var t : T = iter.next();
        t.position = Point.get((t.position.row + delta.row).mod(getHeight()), (t.position.col + delta.col).mod(getWidth()));
      }
    }
    return this;
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

  /** Returns the elements located at the neighbors of the given point
   * Nulls put in place of OOB locations.
   * If filterNulls, doesn't add OOB or null elements
   **/
  public function getNeighborsOf(p : Point, filterNulls : Bool = false) : Array<T> {
    var arr : Array<T> = [];
    for(n in p.getNeighbors()) {
      var t = getAt(n, true);
      if (t != null || !filterNulls) {
        arr.push(t);
      }
    }
    return arr;
  }

  /** Two Array2Ds are equal if they have the same size and contain the same elements.
   * If equalsOp is non-null, uses that to check for equality on T, otherwise uses ==.
   * equalsOp should return true on (null,null).
   *
   * modCount is not checked for equality purposes.
   * Implementing Equitable correctly is left to the subclasses.
   **/
  public function equalsUsing(arr : Array2D<T>, equalsOp : T -> T -> Bool = null) : Bool {
    if (arr == null || getWidth() != arr.getWidth() || getHeight() != arr.getHeight()) {
      return false;
    }

    for(r in 0...getHeight()) {
      for(c in 0...getWidth()) {
        var t1 = get(r,c);
        var t2 = arr.get(r,c);

        if(equalsOp != null && !equalsOp(t1,t2)) return false;
        else if (equalsOp == null && t1 != t2) return false;
      }
    }
    return true;
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
