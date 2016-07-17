package common;

/** A Positionable is any object that has a position in (row,col) form.
 * Implementing classes can be imutable if the setter simply throws
 */
interface Positionable {
  public var position(default,set) : Point;
}

/** A generic Positionable implementation for wrapping simple classes and the like.
 * Tile is immutable by default, trying to set data after initial construction will
 * result in thrown error. To change this behavior, override set_data(..)
 * Position is initally (-1,-1) until set
 **/
class Tile<T> implements Positionable {

  public var data(default, set) : T;
  private var dataSet : Bool;
  public var position(default, set) : Point;


  public function new(t : T = null) {
    data = t;
    dataSet = true;
    position = Point.get(-1,-1);
  }

  public function toString() : String {
    return "Tile(" + data + ")";
  }

  public static function create<T>(t : T = null) : Tile<T> {
    return new Tile<T>(t);
  }

  /** Returns a function that, upon application, returns a fresh tile wrapping the same
   * Inner data. Inner data is not copied, each will reference the same in mem.
   **/
  public static function creator<T>(t : T = null) : Void->Tile<T> {
    return return function(){return create(t);};
  }

  public function set_data(newData : T) : T {
    if (dataSet) throw "Can't change immutable tile, data already set to " + data;
    dataSet = true;
    return data = newData;
  }

  public function set_position(p : Point) : Point {
    return position = p;
  }

}