package view;

import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;

import common.Util;
import common.Point;

using common.IntExtender;

@:abstract class RotatableHexSprite extends HexSprite {

  /** Rotation interaction constants */
  public static var ROTATION_INC : Float = 3;
  public static var ROTATION_DISTANCE = 60;

  /** The target angle to rotate to, in degrees */
  private var angleDelta : Float;

  /** True if this is currently rotating, false otherwise */
  public var isRotating(default, null) : Bool;

  /** Listener to call when this starts rotating. Arg is this PrismSprite */
  public var rotationStartListener(default, default) : RotatableHexSprite -> Void;

  /** Listener to call when this stops rotating. Arg is this PrismSprite */
  public var rotationEndListener(default, default) : RotatableHexSprite -> Void;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    angleDelta = 0;
    isRotating = false;
    rotationStartListener = null;
    rotationEndListener = null;

    //Interaction
    mouseReleasedCallback = onMouseRelease;
  }

  /** Returns the current orientation. Result is only dependable when this isn't currently rotating */
  public inline function getOrientation() : Int {
    return Std.int(-angle/ROTATION_DISTANCE).mod(Util.HEX_SIDES);
  }

  /** Helper that corrects for the current orientation of the Hex.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  public inline function correctForOrientation(side : Int) : Int {
    return (getOrientation() + side).mod(Util.HEX_SIDES);
  }

  /** Helper that uncorrects for the current orientation of the Hex.
   * Performs the reverse of correctForOrientation.
   **/
  public inline function uncorrectForOrientation(side : Int) : Int {
    return (side - getOrientation()).mod(Util.HEX_SIDES);
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

  public override function update(dt : Float) {
    super.update(dt);

    //Check resulting rotation state
    if (angleDelta > 0) {
      angleDelta -= ROTATION_INC;
      angle += ROTATION_INC;
    } else if (angleDelta < 0) {
      angleDelta += ROTATION_INC;
      angle -= ROTATION_INC;
    }
    if (angleDelta == 0 && isRotating) {
      isRotating = false;
      if (rotationEndListener != null) rotationEndListener(this);
    }
  }

  private function onMouseRelease(f : FlxExtendedSprite, x : Int, y : Int) : Void {
    var h = getHitbox();
    var p = FlxG.mouse.getPosition();
    //Extra check that the mouse is still there
    if (h.containsPoint(p)){
      if (HexSprite.CHECK_FOR_REVERSE()) {
        angleDelta -= ROTATION_DISTANCE;
      } else {
        angleDelta += ROTATION_DISTANCE;
      }
      if (! isRotating) {
        isRotating = true;
        if (rotationStartListener != null) rotationStartListener(this);
      }
    }
    h.put();
    p.put();
  }

  public override function isRotatable() : Bool {
    return true;
  }

}
