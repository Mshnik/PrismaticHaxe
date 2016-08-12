package view;

import flixel.addons.display.FlxExtendedSprite.MouseCallback;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import common.*;
import flixel.math.FlxPoint;

class HexSprite extends BaseSprite implements Positionable {

  //Magic number corresponds to graphic size
  public inline static var HEX_SIDE_LENGTH : Float = SCALE * 55;
  public inline static var SCALE : Float = 1.0;

  /** Checks if a mouse click should be treated in reverse */
  public inline static function CHECK_FOR_REVERSE() : Bool {
    return FlxG.keys.checkStatus(FlxKey.SHIFT, FlxInputState.PRESSED);
  }

  /** The position of this HexSprite in the BoardView. (-1,-1) when unset.
   * Mutated if this HexSprite is repositioned in the BoardView.
   **/
  public var position(default, set) : Point;

  /** The rotator currently rotating this to a new position. Null if none */
  public var rotator(default, default) : RotatorSprite;

  /** True if this View is hidden (drawn as opaque and locked from interaction) */
  public var isHidden(default, set) : Bool;

  /** Mouse Handler that was present when isHidden was set to true.
   *   Kept here to avoid deletion, but not registered
   **/
  private var disabledMouseHandeler : MouseCallback;

  /** Constructor for HexSprite
   *
   *  @param x - x position, graphically. 0 if unset
   *  @param y - y position, graphically. 0 if unset
   *
   **/
  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Fields
    angle = 0;
    position = Point.get(-1,-1);
    scale = FlxPoint.get(SCALE,SCALE);
    rotator = null;
    disabledMouseHandeler = null;
    isHidden = false;

    //Input handling
    enableMouseClicks(true, true);
    disableMouseDrag();
    disableMouseThrow();
    disableMouseSpring();
  }

  public inline function set_isHidden(hidden : Bool) : Bool {
    if (hidden == isHidden) return isHidden;

    if (hidden) {
      disabledMouseHandeler = mouseReleasedCallback;
      disableMouseClicks();
      var oldWidth = width;
      var oldHeight = height;
      loadGraphic(AssetPaths.locked_hex__png);
      updateHitbox();
      x -= (width - oldWidth)/2;
      y -= (height - oldHeight)/2;
    } else {
      enableMouseClicks(true, true);
      mouseReleasedCallback = disabledMouseHandeler;
      disabledMouseHandeler = null;
      var oldWidth = width;
      var oldHeight = height;
      loadTrueGraphic();
      updateHitbox();
      x -= (width - oldWidth)/2;
      y -= (height - oldHeight)/2;
    }
    return isHidden = hidden;
  }

  private function loadTrueGraphic() {
    throw "Must be overidden in subclass " + this;
  }

  public inline function set_position(p : Point) : Point {
    return position = p;
  }

  public function isRotatable() : Bool {
    return false;
  }

  public inline function isPrismSprite() : Bool {
    return Std.is(this, PrismSprite);
  }

  public inline function isSinkSprite() : Bool {
    return Std.is(this, SinkSprite);
  }

  public inline function isSourceSprite() : Bool {
    return Std.is(this, SourceSprite);
  }

  public inline function isRotatorSprite() : Bool {
    return Std.is(this, RotatorSprite);
  }

  public inline function asRotatableSprite() : RotatableHexSprite {
    if(Std.is(this, RotatableHexSprite)) return Std.instance(this, RotatableHexSprite);
    throw this + "RotatableHexSprite";
  }

  public inline function asPrismSprite() : PrismSprite {
    if(Std.is(this, PrismSprite)) return Std.instance(this, PrismSprite);
    throw this + " isn't PrismSprite";
  }

  public inline function asSourceSprite() : SourceSprite {
    if(Std.is(this, SourceSprite)) return Std.instance(this, SourceSprite);
    throw this + " isn't SourceSprite";
  }

  public function asSinkSprite() : SinkSprite {
    if(Std.is(this, SinkSprite)) return Std.instance(this, SinkSprite);
    throw this + " isn't SinkSprite";
  }

  public function asRotatorSprite() : RotatorSprite {
    if(Std.is(this, RotatorSprite)) return Std.instance(this, RotatorSprite);
    throw this + " isn't RotatorSprite";
  }
}
