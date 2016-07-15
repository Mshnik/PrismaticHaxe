package;

import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  override public function create() : Void {
    super.create();

    add(new HexSprite(10,10));
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);
  }
}
