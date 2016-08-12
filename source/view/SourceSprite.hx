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
    loadTrueGraphic();

    litColor = Color.NONE;
    mouseReleasedCallback = onMouseRelease;
    colorSwitchListener = null;
  }

  private override function loadTrueGraphic() {
    loadGraphic(AssetPaths.source_back__png, false, 0, 0, true);
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
    color = ColorUtil.toFlxColor(c, true);
    return litColor = c;
  }
}
