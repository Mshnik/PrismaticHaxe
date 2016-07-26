package view;
import common.ColorUtil;
import common.Color;
class SourceSprite extends HexSprite {

  public var litColor(default, set) : Color;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Graphics
    loadGraphic(AssetPaths.source_back__png, false, 0, 0, true);

    //TODO - use rotateGraphic and animations to increase speed
    //    loadRotatedGraphic(AssetPaths.hex_back__png, Std.int(360.0/ROTATION_INC));

    litColor = Color.NONE;
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
