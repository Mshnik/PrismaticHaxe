package game;

/**
 * An instance represents a single hex tile.
 * Each Hex is only ment to belong to a single Board instance at a time,
 * behavior is undefined when a single hext instance is added to multiple boards.
 */
@:abstract class Hex {

  public inline static var SIDES : Int = 6;

  /** Current rotational orientation of this hex. Always in the range [0-(SIDES-1)] */
  public var orientation(default, set) : Int;

  /** True if this hex is currently allowed to connect to adjacent hexes.
   *  False otherwise, such as when this is currently rotating or the like.
   */
  public var acceptConnections(default, set) : Bool;

  /** The position of this hex in the board it belongs to.
   *  Initially (-1,-1) if this doesn't belong to a board.
   *  Mutated if this hex is moved
   **/
  public var position(default, set) : Point;

  public function new() {
    position = Point.get(-1,-1);
    orientation = 0;
    acceptConnections = false;
  }

  public function toString() {
    return "orientation=" + orientation;
  }

  public inline function set_position(newPosition : Point) : Point {
    return position = newPosition;
  }

  /** Shifts this hex's position by dRow and dCol */
  public inline function shift(dRow : Int, dCol : Int) {
    position = position.add(Point.get(dRow, dCol));
  }

  public function set_orientation(newOrientation : Int) : Int {
    var x = orientation;
    var x2 = orientation = Util.mod(newOrientation, SIDES);
    if (x != x2) {
      onRotate();
    }
    return x2;
  }

  public function rotateClockwise() {
    orientation = orientation + 1;
  }

  public function rotateCounterClockwise() {
    orientation = orientation - 1;
  }

  /** Function called whenever the rotation of this hex changes.
   *  Must be overridden by subclasses, but can be empty if nothing should happen when this is rotated
   */

  @abstract public function onRotate() {
    throw "onRotate not overridden";
  }

  public function set_acceptConnections(b : Bool) : Bool {
    return acceptConnections = b;
  }

}
