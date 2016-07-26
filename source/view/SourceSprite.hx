package view;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;
import common.ColorUtil;
import common.Color;
class SourceSprite extends HexSprite {

  /** The color this is currently lighted */
  public var litColor(default, set) : Color;

  /** The listener for when this is clicked to request the next color. Arg when called is this */
  public var colorSwitchListener(default, default) : SourceSprite -> Void;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Graphics
    loadGraphic(AssetPaths.source_back__png, false, 0, 0, true);

    //TODO - use rotateGraphic and animations to increase speed
    //    loadRotatedGraphic(AssetPaths.hex_back__png, Std.int(360.0/ROTATION_INC));

    litColor = Color.NONE;
    mouseReleasedCallback = onMouseRelease;
    colorSwitchListener = null;
  }

  private function onMouseRelease(f : FlxExtendedSprite, x : Int, y : Int) : Void {
    if (colorSwitchListener != null) {
      var h = getHitbox();
      var p = FlxG.mouse.getPosition();
      //Extra check that the mouse is still there
      if (h.containsPoint(p)){
        colorSwitchListener(this);
      }
      h.put();
      p.put();
    }
  }

  public function set_litColor(c : Color) : Color {
    if (c == null) c = Color.NONE;
    return litColor = c;
  }

  public override function update(dt : Float) {
    super.update(dt);
    color = ColorUtil.toFlxColor(litColor, true);
  }

  public override function draw() {
    super.draw();
  }
}
