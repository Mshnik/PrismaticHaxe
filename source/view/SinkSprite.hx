package view;
import common.ColorUtil;
import common.Color;
class SinkSprite extends HexSprite {

  /** The color this is currently lighted */
  public var litColor(default, set) : Color;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Graphics
    loadTrueGraphic();

    //Fields
    litColor = Color.NONE;
    mouseReleasedCallback = null;
  }

  private override function loadTrueGraphic() {
    loadGraphic(AssetPaths.sink_back__png, false, 0, 0, true);
  }

  public function set_litColor(c : Color) : Color {
    if (c == null) c = Color.NONE;
    color = ColorUtil.toFlxColor(c, true);
    return litColor = c;
  }

}
