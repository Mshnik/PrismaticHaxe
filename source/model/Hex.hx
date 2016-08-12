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

  /** True once the id has been set, false until then */
  private var idSet : Bool;

  /** Current rotational orientation of this hex. Always in the range [0-(SIDES-1)].
   * Value is the side index currently point up.
   **/
  public var orientation(default, set) : Int;

  @:isVar public static var UNSET_CONNECTION_GROUP(default, never) = -1;

  /** The connection group this belongs to.
   * Only accepts connections from hexes in the same group.
   * -1 until this is put into a board.
   **/
  public var connectionGroup(default, set) : Int;

  /** The position of this hex in the board it belongs to.
   *  Initially (-1,-1) if this doesn't belong to a board.
   *  Mutated if this hex is moved
   **/
  public var position(default, set) : Point;

  /** An array of light going into the this hex.
   * Has length Util.HEX_SIDES, correct indexing is handled by correctForOrientation(..)
   **/
  private var lightIn : Array<Color>;

  /** True if this has any light in (lightIn contains anything other than Color.NONE) */
  public var hasLightIn(default, null) : Bool;

  /**
   * An array of light coming out of this hex
   * Has length Util.HEX_SIDES, correct indexing is handled by correctForOrientation(..)
   * */
  private var lightOut : Array<Color>;

  /** True if this has any light out (lightOut contains anything other than Color.NONE) */
  public var hasLightOut(default, null) : Bool;

  /** A listener to call when this rotates. Args are (this, oldOrientation) */
  public var rotationListener : Hex->Int->Void;

  public function new() {
    position = Point.get(-1,-1);
    orientation = 0;
    idSet = false;
    id = nextID++;
    connectionGroup = UNSET_CONNECTION_GROUP;
    lightIn = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    hasLightIn = false;
    lightOut = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    hasLightOut = false;
  }

  public function toString() {
    return "id= " + id;
  }

  public function set_id(i : Int) : Int {
    if (idSet) {
      throw "Can't reset final ID field";
    }
    idSet = true;
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

  public function set_connectionGroup(g : Int) : Int {
    if (connectionGroup != g) {
      resetLight();
    }
    return connectionGroup = g;
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
    hasLightIn = false;
    hasLightOut = false;
    return arr;
  }

  /** Helper for addLightIn. Updates hasLightIn hasLightOut. Calling this should be part of addLightIn impl */
  private function updateHasLightInOut() {
    hasLightIn = false;
    hasLightOut = false;
    for(c in lightIn) {
      if (c != Color.NONE) hasLightIn = true;
    }
    for(c in lightOut) {
      if (c != Color.NONE) hasLightOut = true;
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

  public inline function asHex() : Hex {
    return this;
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

  /** Determines if the this and h are functionally equivalent.
   *  This compares their attributes, not their current state.
   *
   *  Used:
   *   - orientation
   *
   *  Not Used:
   *   - id
   *   - acceptConnections
   *   - position
   *   - lightIn
   *   - lightOut
   *   - rotationListener
   *
   * Additionally, subclasses should override and check their properties as well
   **/
  public function equals(h : Hex) : Bool {
    return h != null && orientation == h.orientation;
  }
}
