package common;
class Util {
  private function new() {
  }

  /** A mathematically correct mod operator, that returns in the range [0,b) */

  public static inline function mod(a : Int, b : Int) : Int {
    if (b <= 0) throw "Bad mod base " + b;
    return ((a % b) + b) % b;
  }

  /** Returns true iff the two arrays contain equal elements */

  public static function arrayEquals(expected : Array<Dynamic>, actual : Array<Dynamic>) : Bool {
    if (expected.length != actual.length) return false;

    var iter1 = expected.iterator();
    var iter2 = actual.iterator();
    while (iter1.hasNext() && iter2.hasNext()) {
      var v1 : Dynamic = iter1.next();
      var v2 : Dynamic = iter2.next();

      if (Std.is(v1, Array) && Std.is(v2, Array)) {
        if (!arrayEquals(Std.instance(v1, Array), Std.instance(v2, Array))) return false;
      } else {
        if (v1 != v2) return false;
      }
    }
    return true;
  }

  /** Creates an empty (all null) array of length, for the given type */

  @:generic public static function emptyArray<T>(ArrayType : Class<T>, length : Int) : Array<T> {
    if (length < 0) {
      throw "Can't create array of length " + length;
    }
    if (length == 0) {
      return [];
    }

    var arr = new Array<T>();
    arr[length - 1] = null;
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
}