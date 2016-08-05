package view;

import common.ColorUtil;
import common.Color;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxColor;

import common.Util;
import common.Point;
import view.HexSprite;

using flixel.util.FlxSpriteUtil;
using common.ArrayExtender;

class PrismSprite extends RotatableHexSprite {

  /** Returns a graphic point that represents the graphic location given side.
   * Doesn't correct for rotation of sprite
   */
  private static var HEX_MIDPOINTS : Array<FlxPoint>;

  /** Drawing styles for the connectors */
  private static var CONNECTOR_FRAME_WIDTH : Float;
  private static var CONNECTOR_FRAME_HEIGHT : Float;
  private static var CONNECTOR_FRAME_CENTER_PT : FlxPoint;
  private static var CONNECTOR_LINE_STYLE : LineStyle;
  private static var connectorSprites : Array<Array<FlxSprite>>;

  public static function initGeometry() {
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

  /** 2D array of bools for connectors that are currently lit, listed as from,to */
  private var litArr : Array<Array<Bool>>;

  /** Colors that connectors are currently set to. Listed as from,to */
  private var colorArr : Array<Array<Color>>;

  /** Array of locations where this has a connector, as (from,to) */
  private var hasConnector : Array<Point>;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Graphics
    loadGraphic(AssetPaths.hex_back__png, false, 0, 0, true);

    //TODO - use rotateGraphic and animations to increase speed
    //    loadRotatedGraphic(AssetPaths.hex_back__png, Std.int(360.0/ROTATION_INC));

    //Fields
    litArr = Util.arrayOf(null, Util.HEX_SIDES);
    colorArr = Util.arrayOf(null, Util.HEX_SIDES);
    for(i in 0...Util.HEX_SIDES){
      litArr[i] = Util.arrayOf(false, Util.HEX_SIDES);
      colorArr[i] = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    }
    hasConnector = [];
  }

  public function setLighting(from : Int, to : Int, lit : Bool) : PrismSprite {
    litArr[from][to] = lit;
    if (colorArr[from][to] == colorArr[to][from]) {
      litArr[to][from] = lit;
    }
    return this;
  }

  public function addConnection(color : Color, from : Int, to : Int, bidirectional : Bool = true) : PrismSprite {
    colorArr[from][to] = color;
    if (bidirectional) {
      colorArr[to][from] = color;
    }
    if (bidirectional) {
      hasConnector.remove(Point.get(to,from));
    }
    hasConnector.push(Point.get(from, to));
    return this;
  }

  public override function draw() : Void {
    super.draw();
    for(p in hasConnector) {
      var lit = litArr[uncorrectForOrientation(p.row)][uncorrectForOrientation(p.col)];
      connectorSprites[p.row][p.col].color = ColorUtil.toFlxColor(colorArr[p.row][p.col], lit);
      stamp(connectorSprites[p.row][p.col],0,0);
    }
  }
}

/** Can't delete this without crashing, not sure why... */
class UNUSED {}
