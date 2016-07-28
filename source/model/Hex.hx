package model;

/**
 * An instance represents a single hex tile.
 * Each Hex is only ment to belong to a single Board instance at a time,
 * behavior is undefined when a single hext instance is added to multiple boards.
 */
import common.*;
using common.IntExtender;

@:abstract class Hex implements Positionable {

  /** 0 Used to denote uninitialized ID, thus 1 is the first valid ID */
  private static var nextID : Int = 1;

  public static function resetIDs() {
    nextID = 1;
  }

  /** The unique id assigned to this Hex upon instantiation. */
  @final public var id(default, set) : Int;

  /** Current rotational orientation of this hex. Always in the range [0-(SIDES-1)].
   * Value is the side index currently point up.
   **/
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
   * Has length Util.HEX_SIDES, correct indexing is handled by correctForOrientation(..)
   **/
  private var lightIn : Array<Color>;

  /**
   * An array of light coming out of this hex
   * Has length Util.HEX_SIDES, correct indexing is handled by correctForOrientation(..)
   * */
  private var lightOut : Array<Color>;

  /** A listener to call when this rotates. Args are (this, oldOrientation) */
  public var rotationListener : Hex->Int->Void;

  public function new() {
    position = Point.get(-1,-1);
    orientation = 0;
    acceptConnections = true;
    id = nextID++;
    lightIn = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    lightOut = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
  }

  public function toString() {
    return "id= " + id;
  }

  public function set_id(i : Int) : Int {
    if (id != 0) {
      throw "Can't reset final ID field";
    }
    return id = i;
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
    var x2 = orientation = newOrientation.mod(Util.HEX_SIDES);
    if (rotationListener != null && x != x2) {
      rotationListener(this,x);
    }
    return x2;
  }

  public function rotateClockwise() {
    orientation = orientation - 1;
  }

  public function rotateCounterClockwise() {
    orientation = orientation + 1;
  }

  public function set_acceptConnections(b : Bool) : Bool {
    if (! b) {
      resetLight();
    }
    return acceptConnections = b;
  }

  /** Helper that corrects for the current orientation of the Hex.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  public inline function correctForOrientation(side : Int) : Int {
    return (orientation + side).mod(Util.HEX_SIDES);
  }

  /** Helper that uncorrects for the current orientation of the Hex.
   * Performs the reverse of correctForOrientation.
   **/
  public inline function uncorrectForOrientation(side : Int) : Int {
    return (side - orientation).mod(Util.HEX_SIDES);
  }

  /** Helper that corrects for the current orientation of the Hex.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  public inline function correctPtForOrientation(point : Point) : Point {
    return Point.get(correctForOrientation(point.row), correctForOrientation(point.col));
  }

  /** Helper that uncorrects for the current orientation of the Hex.
   * Performs the reverse of correctPtForOrientation
   **/
  public inline function uncorrectPtForOrientation(point : Point) : Point {
    return Point.get(uncorrectForOrientation(point.row), uncorrectForOrientation(point.col));
  }

/** Returns the light coming on the given side (corrected for orientation) */
  public inline function getLightIn(side : Int) : Color {
    return lightIn[correctForOrientation(side)];
  }

  /** Returns a write-safe copy of the light entering this Hex */
  public inline function getLightInArray() : Array<Color> {
    var arr : Array<Color> = [];
    for(i in 0...Util.HEX_SIDES) {
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
    for(i in 0...Util.HEX_SIDES) {
      arr[i] = getLightOut(i);
    }
    return arr;
  }

  /** Resets the lighting status of this Hex to default (all unlit).
   * Returns an array of the sides that this was providing light to, so recursive recalculation
   * can be done
   **/
  public function resetLight() : Array<Int> {
    var arr : Array<Int> = [];
    for(i in 0...Util.HEX_SIDES) {
      if(lightIn != null) lightIn[i] = Color.NONE;
      if(lightOut != null) {
        if (lightOut[i] != Color.NONE) {
          arr.push(i);
        }
        lightOut[i] = Color.NONE;
      }
    }
    return arr;
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

  public inline function isPrism() : Bool {
    return Std.is(this, Prism);
  }

  public inline function isSink() : Bool {
    return Std.is(this, Sink);
  }

  public inline function isSource() : Bool {
    return Std.is(this, Source);
  }

  public inline function isRotator() : Bool {
    return Std.is(this, Rotator);
  }

  public inline function asPrism() : Prism {
    if(Std.is(this, Prism)) return Std.instance(this, Prism);
    throw this + " isn't Prism";
  }

  public inline function asSource() : Source {
    if(Std.is(this, Source)) return Std.instance(this, Source);
    throw this + " isn't Source";
  }

  public function asSink() : Sink {
    if(Std.is(this, Sink)) return Std.instance(this, Sink);
    throw this + " isn't Sink";
  }

  public function asRotator() : Rotator {
    if(Std.is(this, Rotator)) return Std.instance(this, Rotator);
    throw this + " isn't Rotator";
  }
}
