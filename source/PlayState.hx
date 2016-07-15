package;

import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  override public function create() : Void {
    super.create();

    populate();
  }

  public function populate() {
    add(new HexSprite(200,200));
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);
  }
}
