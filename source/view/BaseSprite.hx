package view;

import flixel.util.FlxCollision;
import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;

/**
 *
 *
 *  IMPORTANT - had to make a change to FlxMouseControl to fire events on right and middle clicks
 *
 *
 **/
class BaseSprite extends FlxExtendedSprite {

  public var leftMouseInteraction(default, null) : Bool;
  public var rightMouseInteraction(default, null) : Bool;
  public var middleMouseInteraction(default, null) : Bool;

  /**
	 * Creates a white 8x8 square FlxExtendedSprite at the specified position.
	 * Optionally can load a simple, one-frame graphic instead.
	 *
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);

    leftMouseInteraction = false;
    rightMouseInteraction = false;
    middleMouseInteraction = false;
  }

  public override function update(dt : Float) {
    leftMouseInteraction = false;
    rightMouseInteraction = false;
    middleMouseInteraction = false;

    super.update(dt);

    if (isPressed) {
      leftMouseInteraction = true;
    }

    #if !FLX_NO_MOUSE
    #if !FLX_NO_MOUSE_ADVANCED
    if (isPressed == false && FlxG.mouse.justPressedMiddle) {
      middleMouseInteraction = checkForClickAdv();
    }
    if (isPressed == false && FlxG.mouse.justPressedRight) {
      rightMouseInteraction = checkForClickAdv();
    }
    #end
    #end
  }

/**
	 * Checks if the mouse is over this sprite and pressed, then does a pixel
	 * perfect check if needed and adds it to the FlxMouseControl check stack.
	 *
	 * This version of checkForClick checks all mouse buttons
	 */
  public function checkForClickAdv():Bool
  {
    #if !FLX_NO_MOUSE
    #if !FLX_NO_MOUSE_ADVANCED
    if (mouseOver && (FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight))
    {
      //	If we don't need a pixel perfect check, then don't bother running one! By this point we know the mouse is over the sprite already
      if (_clickPixelPerfect == false && _dragPixelPerfect == false)
      {
        FlxMouseControl.addToStack(this);
        return true;
      }

      if (_clickPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, _clickPixelPerfectAlpha))
      {
        FlxMouseControl.addToStack(this);
        return true;
      }

      if (_dragPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, _dragPixelPerfectAlpha))
      {
        FlxMouseControl.addToStack(this);
        return true;
      }
    }
    #end
    #end
    return false;
  }


}
