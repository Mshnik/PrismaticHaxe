package view;
import view.HexSprite;
import common.Util;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil.LineStyle;
import model.Hex;
import common.Point;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;

class PrismSprite extends HexSprite {

  private static var CONNECTOR_FRAME_WIDTH : Float;
  private static var CONNECTOR_FRAME_HEIGHT : Float;
  private static var CONNECTOR_FRAME_CENTER_PT : FlxPoint;
  private static var CONNECTOR_LINE_STYLE : LineStyle;
  private static var connectorSprites : Array<Array<FlxSprite>>;

  public static function __init__() {

    CONNECTOR_FRAME_WIDTH = 2 * HexSprite.HEX_SIDE_LENGTH;
    CONNECTOR_FRAME_HEIGHT = Util.ROOT3 * HexSprite.HEX_SIDE_LENGTH;
    CONNECTOR_LINE_STYLE = {color : FlxColor.GREEN, thickness : 2};
    CONNECTOR_FRAME_CENTER_PT = FlxPoint.get(CONNECTOR_FRAME_WIDTH/2, CONNECTOR_FRAME_HEIGHT/2);

    var createConnector = function(r : Int, c : Int) : FlxSprite {
      var s = new FlxSprite();
      s.makeGraphic(Std.int(CONNECTOR_FRAME_WIDTH)+1,
                    Std.int(CONNECTOR_FRAME_HEIGHT)+1,
                    FlxColor.TRANSPARENT,
                    true, "base_connector " + r + c);

      var start = getGraphicPositionOfSide(r);
      var end = getGraphicPositionOfSide(c);
      var middle = Util.linearInterpolate([start, end, CONNECTOR_FRAME_CENTER_PT]);

      s.drawLine(start.x, start.y, middle.x ,middle.y, CONNECTOR_LINE_STYLE);
      s.drawLine(middle.x, middle.y, end.x ,end.y, CONNECTOR_LINE_STYLE);

      //s.drawCurve(start.x, start.y, middle.x, middle.y, end.x, end.y, FlxColor.RED, CONNECTOR_LINE_STYLE);

      start.put();
      end.put();
      middle.put();

      return s;
    }

    connectorSprites = [];
    for(r in 0...Hex.SIDES) {
      connectorSprites[r] = [];
      for(c in 0...Hex.SIDES) {
        connectorSprites[r][c] = createConnector(r,c);
      }
    }
  }

  /** Returns a graphic point that represents the graphic location given side.
   * Doesn't correct for rotation of sprite
   **/
  public static inline function getGraphicPositionOfSide(side : Int) : FlxPoint {
    switch(side) {
      case 0: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH, 0);
      case 1: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * (2 + Util.ROOT3)/2, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3-1)/2));
      case 2: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * (2 + Util.ROOT3)/2, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3+1)/2));
      case 3: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH, HexSprite.HEX_SIDE_LENGTH * Util.ROOT3);
      case 4: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * (2 - Util.ROOT3)/2, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3+1)/2));
      case 5: return FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * (2 - Util.ROOT3)/2, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3-1)/2));
      default: throw "Illegal side value " + side;
    }
  }

  private var sample = new ConnectorSprite(0,0,FlxColor.YELLOW);

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);
  }

  public function addConnection(baseColor : FlxColor, from : Int, to : Int) : PrismSprite {
    //connectorArr.set(Point.get(from,to),new ConnectorSprite(baseColor, from, to));
    return this;
  }


  public override function draw() : Void {
    super.draw();
    stamp(connectorSprites[position.row][position.col], 0, 0);
  }
}

class ConnectorSprite extends FlxSprite {

  private var connectionColor : FlxColor;
  private var sides : Point;
  public var isLit : Bool;

  public function new(c : FlxColor, s1 : Int, s2 : Int) {
    super();
    this.connectionColor = c;
    sides = Point.get(s1,s2);
    this.isLit = false;
  }


}
