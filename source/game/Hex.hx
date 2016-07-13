package game;
@abstract class Hex {

  @final public static var SIDES : Int = 6;

  /** Current rotational orientation of this hex. Always in the range [0-(SIDES-1)] */
  public var orientation(default, set) : Int;

  public function new() {
    orientation = 0;
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

  @abstract public function onRotate() {
    throw "onRotate not overridden";
  }

}
