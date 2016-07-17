package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  override public function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.CYAN);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    populate();
  }

  public function populate() {
    add(new HexSprite(200,200));
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);
  }
}
