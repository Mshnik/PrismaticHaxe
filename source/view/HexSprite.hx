package view;

import common.Positionable;
import common.Point;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxExtendedSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;
class HexSprite extends BaseSprite implements Positionable {

  private inline static var ROTATION_INC : Float = 3.0;
  private inline static var ROTATION_DISTANCE : Float = 60.0;

  private inline static var REVERSE_KEY = FlxKey.SHIFT;

  /** The target angle to rotate to, in degrees */
  private var angleDelta : Float;

  /** The position of this HexSprite in the BoardView. (-1,-1) when unset.
   * Mutated if this HexSprite is repositioned in the BoardView.
   **/
  public var position(default, set) : Point;

  public function new(x : Float, y : Float) {
    super(x,y);

    //Fields
    angleDelta = 0;
    angle = 0;
    position = Point.get(-1,-1);

    //Graphics
    loadGraphic(AssetPaths.hex_back__png);

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
  }


  public inline function set_position(p : Point) : Point {
    return position = p;
  }

}
