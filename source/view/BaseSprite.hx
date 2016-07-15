package view;

import flixel.addons.display.FlxExtendedSprite;

class BaseSprite extends FlxExtendedSprite {

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
  }



}
