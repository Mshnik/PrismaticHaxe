package game;

/**
 * An instance represents a single hex tile.
 * Each Hex is only ment to belong to a single Board instance at a time,
 * behavior is undefined when a single hext instance is added to multiple boards.
 */
import common.Positionable;
import common.Util;
import common.Point;
@:abstract class Hex implements Positionable {

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

  /** An array of light going into the this hex.
   * Has length Hex.SIDES, correct indexing is handled by correctForOrientation(..)
   **/
  private var lightIn : Array<Color>;

  /**
   * An array of light coming out of this hex
   * Has length Hex.SIDES, correct indexing is handled by correctForOrientation(..)
   * */
  private var lightOut : Array<Color>;

  /** A listener to call when this rotates. Args are (this, oldOrientation) */
  public var rotationListener : Hex->Int -> Void;

  public function new() {
    position = Point.get(-1,-1);
    orientation = 0;
    acceptConnections = false;
    lightIn = Util.arrayOf(Color.NONE, Hex.SIDES);
    lightOut = Util.arrayOf(Color.NONE, Hex.SIDES);
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
    if (rotationListener != null && x != x2) {
      rotationListener(this,x);
    }
    return x2;
  }

  public function rotateClockwise() {
    orientation = orientation + 1;
  }

  public function rotateCounterClockwise() {
    orientation = orientation - 1;
  }

  public function set_acceptConnections(b : Bool) : Bool {
    return acceptConnections = b;
  }

  /** Helper that corrects for the current orientation of the Prism.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  private inline function correctForOrientation(side : Int) : Int {
    return Util.mod(orientation + side, Hex.SIDES);
  }

/** Returns the light coming on the given side (corrected for orientation) */
  public inline function getLightIn(side : Int) : Color {
    return lightIn[correctForOrientation(side)];
  }

  /** Returns a write-safe copy of the light entering this Hex */
  public inline function getLightInArray() : Array<Color> {
    var arr : Array<Color> = [];
    for(i in 0...Hex.SIDES) {
      arr[i] = getLightIn(i);
    }
    return arr;
  }

  /** Returns the light going out the given side (corrected for orientation) */
  public inline function getLightOut(side : Int) : Color {
    return lightOut[correctForOrientation(side)];
  }

  /** Returns a write-safe copy of the light leaving this Hex */
  public inline function getLightOutArray() : Array<Color> {
    var arr : Array<Color> = [];
    for(i in 0...Hex.SIDES) {
      arr[i] = getLightOut(i);
    }
    return arr;
  }

  /** Helper that resets the lighting status of this Hex to default (all unlit) */
  private function resetLight() {
    for(i in 0...Hex.SIDES) {
      if(lightIn != null) lightIn[i] = Color.NONE;
      if(lightOut != null) lightOut[i] = Color.NONE;
    }
  }

  /**
   * Abstract function to be implemented by subclasses.
   * Called when light of color c is added on side.
   * Should make alterations to lightIn and lightOut as necessary.
   * Return is an array of the sides that are newly outputting light, for recursive use.
   **/
  public function addLightIn(side : Int, c : Color) : Array<Int> {
    throw "Add Light not implemented";
  }
}
