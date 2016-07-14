package game;
@abstract class Hex {

  @final public static var SIDES : Int = 6;

  /** Current rotational orientation of this hex. Always in the range [0-(SIDES-1)] */
  public var orientation(default, set) : Int;

  /** True if this hex is currently allowed to connect to adjacent hexes.
   *  False otherwise, such as when this is currently rotating or the like.
   */
  public var acceptConnections(default, set) : Bool;

  public function new() {
    orientation = 0;
    acceptConnections = false;
  }

  public function toString() {
    return "orientation=" + orientation;
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
