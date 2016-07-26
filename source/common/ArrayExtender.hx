package common;
class ArrayExtender {

  /** Returns true iff t is in arr, by the == operation */
  @:generic public inline static function contains<T>(arr : Array<T>, t : T) : Bool {
    for(t2 in arr) {
      if (t == t2) return true;
    }
    return false;
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

}
