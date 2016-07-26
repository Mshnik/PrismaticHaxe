package view;

import common.*;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxExtendedSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;

using common.IntExtender;

class HexSprite extends BaseSprite implements Positionable {

  //Magic number corresponds to graphic size
  public inline static var HEX_SIDE_LENGTH : Float = SCALE * 55.5;
  public inline static var SCALE : Float = 1.0;

  private inline static var ROTATION_INC : Float = 3.0;
  private inline static var ROTATION_DISTANCE : Int = 60;

  private inline static var REVERSE_KEY = FlxKey.SHIFT;

  /** The target angle to rotate to, in degrees */
  private var angleDelta : Float;

  /** True if this is currently rotating, false otherwise */
  public var isRotating(default, null) : Bool;

  /** Listener to call when this starts rotating. Arg is this HexSprite */
  public var rotationStartListener(default, default) : HexSprite -> Void;

  /** Listener to call when this stops rotating. Arg is this HexSprite */
  public var rotationEndListener(default, default) : HexSprite -> Void;

  /** The position of this HexSprite in the BoardView. (-1,-1) when unset.
   * Mutated if this HexSprite is repositioned in the BoardView.
   **/
  public var position(default, set) : Point;

  /** Constructor for HexSprite
   *
   *  @param x - x position, graphically. 0 if unset
   *  @param y - y position, graphically. 0 if unset
   *
   **/
  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Fields
    angleDelta = 0;
    angle = 0;
    isRotating = false;
    position = Point.get(-1,-1);
    rotationStartListener = null;
    rotationEndListener = null;
    scale = FlxPoint.get(SCALE,SCALE);

    //Input handling
    mouseReleasedCallback = onMouseRelease;
    enableMouseClicks(true, true);
    disableMouseDrag();
    disableMouseThrow();
    disableMouseSpring();
  }

  private function onMouseRelease(f : FlxExtendedSprite, x : Int, y : Int) : Void {
    var h = getHitbox();
    var p = FlxG.mouse.getPosition();
    //Extra check that the mouse is still there
    if (h.containsPoint(p)){
      if (FlxG.keys.checkStatus(REVERSE_KEY, FlxInputState.PRESSED)) {
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

  public override function update(dt : Float) {
    //Check rotation state before calling super

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

  public inline function set_position(p : Point) : Point {
    return position = p;
  }

  /** Returns the current orientation. Result is only dependable when this isn't currently rotating */
  public inline function getOrientation() : Int {
    return Std.int(-angle/ROTATION_DISTANCE).mod(Util.HEX_SIDES);
  }

  /** Helper that corrects for the current orientation of the Prism.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  public inline function correctForOrientation(side : Int) : Int {
    return (getOrientation() + side).mod(Util.HEX_SIDES);
  }


  public inline function isPrismSprite() : Bool {
    return Std.is(this, PrismSprite);
  }

//  public inline function isSink() : Bool {
//    return Std.is(this, Sink);
//  }
//
  public inline function isSourceSprite() : Bool {
    return Std.is(this, SourceSprite);
  }

  public inline function asPrismSprite() : PrismSprite {
    if(Std.is(this, PrismSprite)) return Std.instance(this, PrismSprite);
    throw this + " isn't PrismSprite";
  }

  public inline function asSourceSprite() : SourceSprite {
    if(Std.is(this, SourceSprite)) return Std.instance(this, SourceSprite);
    throw this + " isn't SourceSprite";
  }
//
//  public function asSink() : Sink {
//    if(Std.is(this, Sink)) return Std.instance(this, Sink);
//    throw this + " isn't SINK";
//  }
}
