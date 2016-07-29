package common;
class ArrayExtender {

  /** Returns true iff t is in arr, by the == operation */
  @:generic public static function contains<T>(arr : Array<T>, t : T) : Bool {
    for(t2 in arr) {
      if (t == t2) return true;
    }
    return false;
  }

  /** Returns true iff the two arrays contain equal elements.
   * Recurses on array elements until a non-array element is hit.
   **/
  public static function equals(arr : Array<Dynamic>, other : Array<Dynamic>) : Bool {
    if (arr.length != other.length) return false;

    var iter1 = arr.iterator();
    var iter2 = other.iterator();
    while (iter1.hasNext() && iter2.hasNext()) {
      var v1 : Dynamic = iter1.next();
      var v2 : Dynamic = iter2.next();

      if (Std.is(v1, Array) && Std.is(v2, Array)) {
        if (!equals(Std.instance(v1, Array),(Std.instance(v2, Array)))) return false;
      } else {
        if (v1 != v2) return false;
      }
    }
    return true;
  }

  /** Fold Left operation, as usually defined functionally */
  @:generic public inline static function foldLeft<T,R>(arr : Array<T>, start : R, f : T->R->R) : R {
    for (t in arr) {
      start = f(t,start);
    }
    return start;
  }

  /** Removes duplicates (using ==) from the given array. Removes in place, but returns a reference */
  @:generic public static function removeDups<T>(arr : Array<T>) : Array<T> {
    var i = 0;
    while(i < arr.length) {
      if (arr.indexOf(arr[i]) < i) {
        arr.remove(arr[i]);
      } else {
        i++;
      }
    }
    return arr;
  }

  /**
   * Rotates once forward - takes the element at the end of the array and puts it at the beginning
   * Shifting all other elements forward one
   * Returns a reference to the passed in array, though the change is done in place.
   **/

  @:generic public static inline function rotateForward<T>(arr : Array<T>) : Array<T> {
    arr.unshift(arr.pop());
    return arr;
  }

  /**
   * Rotates once backwards - takes the element at the front of the array and puts it at the end
   * Shifting all other elements backward one
   * Returns a reference to the passed in array, though the change is done in place.
   **/

  @:generic public static inline function rotateBackward<T>(arr : Array<T>) : Array<T> {
    arr.push(arr.shift());
    return arr;
  }

  /** Pretty prints the given 2D array */
  @:generic public inline static function prettyPrint<T>(arr : Array<Array<T>>) : Void {
    if (arr.length == 0) trace("[]");
    trace("[");
    for(a in arr) {
      trace(a);
    }
    trace("]");
  }

  /** Convienence function that maps each element in an Array<Array<T>>.
   * Can't fully map within Array2D because of the positionable requirement.
   **/
  @:generic public inline static function map2D<T,S>(arr : Array<Array<T>>, f : T -> S) : Array<Array<S>> {
    var m = function(a : Array<T>) : Array<S> {
      return a.map(f);
    }
    return arr.map(m);
  }

}
