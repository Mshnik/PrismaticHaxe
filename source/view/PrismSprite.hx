package view;

import common.ColorUtil;
import common.Color;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxColor;

import common.Util;
import common.Point;
import model.Hex;
import view.HexSprite;

using flixel.util.FlxSpriteUtil;

class PrismSprite extends HexSprite {

  /** Returns a graphic point that represents the graphic location given side.
   * Doesn't correct for rotation of sprite
   */
  private static var HEX_MIDPOINTS : Array<FlxPoint>;

  private static var CONNECTOR_FRAME_WIDTH : Float;
  private static var CONNECTOR_FRAME_HEIGHT : Float;
  private static var CONNECTOR_FRAME_CENTER_PT : FlxPoint;
  private static var CONNECTOR_LINE_STYLE : LineStyle;
  private static var connectorSprites : Array<Array<FlxSprite>>;

  private static function __init__() {

    HEX_MIDPOINTS = [
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH, 0),
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * 7/4, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3-1)/2)),
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH * 7/4, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3+1)/2)),
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH, HexSprite.HEX_SIDE_LENGTH * Util.ROOT3),
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH / 4, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3+1)/2)),
      FlxPoint.get(HexSprite.HEX_SIDE_LENGTH / 4, (HexSprite.HEX_SIDE_LENGTH * (Util.ROOT3-1)/2))
    ];

    CONNECTOR_FRAME_WIDTH = 2 * HexSprite.HEX_SIDE_LENGTH;
    CONNECTOR_FRAME_HEIGHT = Util.ROOT3 * HexSprite.HEX_SIDE_LENGTH;
    CONNECTOR_LINE_STYLE = {color : FlxColor.WHITE, thickness : 3};
    CONNECTOR_FRAME_CENTER_PT = FlxPoint.get(CONNECTOR_FRAME_WIDTH/2, CONNECTOR_FRAME_HEIGHT/2);

    var createConnector = function(r : Int, c : Int) : FlxSprite {
      var s = new FlxSprite();
      s.makeGraphic(Std.int(CONNECTOR_FRAME_WIDTH)+1,
                    Std.int(CONNECTOR_FRAME_HEIGHT)+1,
                    FlxColor.TRANSPARENT,
                    true, "base_connector " + r + c);

      var start = HEX_MIDPOINTS[r];
      var end = HEX_MIDPOINTS[c];
      var middle = Util.linearInterpolate([start, end, CONNECTOR_FRAME_CENTER_PT]);
      
      s.drawCurve(start.x, start.y, middle.x, middle.y, end.x, end.y, FlxColor.TRANSPARENT, CONNECTOR_LINE_STYLE);

      middle.put();

      return s;
    }

    connectorSprites = [];
    for(r in 0...Util.HEX_SIDES) {
      connectorSprites[r] = [];
      for(c in 0...Util.HEX_SIDES) {
        connectorSprites[r][c] = createConnector(r,c);
      }
    }
  }

  private var litArr : Array<Array<Bool>>;
  private var colorArr : Array<Array<Color>>;
  private var hasConnector : Array<Point>;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    litArr = Util.arrayOf(null, Util.HEX_SIDES);
    colorArr = Util.arrayOf(null, Util.HEX_SIDES);
    hasConnector = [];
    for(i in 0...Util.HEX_SIDES){
      litArr[i] = Util.arrayOf(false, Util.HEX_SIDES);
      colorArr[i] = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    }

  }

  public function setLighting(from : Int, to : Int, lit : Bool) : PrismSprite {
    litArr[from][to] = lit;
    return this;
  }

  public function addConnection(color : Color, from : Int, to : Int) : PrismSprite {
    colorArr[from][to] = color;
    if (color != Color.NONE) {
      hasConnector.push(Point.get(from, to));
    } else {
      hasConnector.remove(Point.get(from, to));
    }
    return this;
  }

  public override function draw() : Void {
    super.draw();
    for(p in hasConnector) {
      connectorSprites[p.row][p.col].color = ColorUtil.toFlxColor(colorArr[p.row][p.col], litArr[p.row][p.col]);
      stamp(connectorSprites[p.row][p.col],0,0);
    }
  }
}

/** Can't delete this without crashing, not sure why... */
class UNUSED {}
