package view;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxExtendedSprite;
import flixel.math.FlxPoint;
import game.Hex;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;
class HexSprite extends BaseSprite {

  private inline static var ROTATION_INC = 1.5;
  private inline static var ROTATION_DISTANCE : Float = 60.0;

  private inline static var REVERSE_KEY = FlxKey.SHIFT;

  /** The target angle to rotate to, in degrees. Should always be in (-360,360) */
  private var angleDelta : Float;

  public function new(x : Float, y : Float) {
    super(x,y);

    angleDelta = 0;
    angle = 0;

    scale = FlxPoint.get(10,10);
    updateHitbox();

    //Input handling
    mouseReleasedCallback = onMouseRelease;
    disableMouseDrag();
    disableMouseThrow();
    disableMouseSpring();
  }

  private function onMouseRelease(f : FlxExtendedSprite, x : Int, y : Int) : Void {
    if (FlxG.keys.checkStatus(REVERSE_KEY, FlxInputState.PRESSED)) {
      angleDelta -= ROTATION_DISTANCE;
    } else {
      angleDelta += ROTATION_DISTANCE;
    }
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


}
