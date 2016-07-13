package ;
class Util {
  private function new() {
  }

  /** A mathematically correct mod operator, that returns in the range [0,b) */
  public static inline function mod(a : Int, b : Int) : Int {
    if (b <= 0) throw "Bad mod base " + b;
    return ((a%b)+b)%b;
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
    arr[length-1] = null;
    return arr;
  }
}
