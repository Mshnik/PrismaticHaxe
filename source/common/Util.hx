package common;
import flixel.math.FlxPoint;
class Util {
  private function new() {}

  @:isVar public static var HEX_SIDES(default, never) : Int = 6;

  public static var ROOT2 : Float;
  public static var ROOT3 : Float;

  private static function __init__() {
    ROOT2 = Math.sqrt(2);
    ROOT3 = Math.sqrt(3);
  }

  /** Returns true iff o is null. For use in filtering */
  public static function isNull(a : Dynamic) : Bool {
    return a == null;
  }

  /** Returns true iff o is nonnull. For use in filtering */
  public static function isNonNull(a : Dynamic) : Bool {
    return a != null;
  }

  public static inline function degToRad(d : Float) : Float {
    return d * Math.PI / 180.0;
  }

  public static inline function radToDeg(r : Float) : Float {
    return r / Math.PI * 180.0;
  }

  /** Creates an empty (all null) array of length, for the given type */

  @:generic public inline static function emptyArray<T>(ArrayType : Class<T>, length : Int) : Array<T> {
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

  /** Creates an array filled with the given T */
  @:generic public inline static function arrayOf<T>(t : T, length : Int) : Array<T> {
    var arr : Array<T> = [];
    for(i in 0...length) {
      arr.push(t);
    }
    return arr;
  }

  /** Creates an array out of the given iterator (and exhausts it) */
  @:generic public inline static function toArray<T>(iter : Iterator<T>) : Array<T> {
    var arr : Array<T> = [];
    while(iter.hasNext()) {
      arr.push(iter.next());
    }
    return arr;
  }

  /** Linearly interpolates the given points.
   * If dispose, calls put() on points in array before returning. Do this if points are not
   * needed after this call
   **/
  public static inline function linearInterpolate(points : Array<FlxPoint>, dispose : Bool = false) : FlxPoint {
    var p = FlxPoint.get(0,0);
    for(pt in points) {
      p.addPoint(pt.scale(1/points.length));
      if (dispose) {
        pt.put();
      } else {
        pt.scale(points.length);
      }
    }
    return p;
  }
}
