package view;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.addons.display.FlxExtendedSprite;
import common.ColorUtil;
import common.Color;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxColor;

import common.Util;
import common.Point;
import view.HexSprite;

using common.IntExtender;
using flixel.util.FlxSpriteUtil;

class PrismSprite extends HexSprite {

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

  /** Rotation interaction constants */
  private static var ROTATION_INC : Float;
  private static var ROTATION_DISTANCE;
  private static var REVERSE_KEY;

  public static function __init__() {
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

    ROTATION_DISTANCE = 60;
    ROTATION_INC = 3.0;
    REVERSE_KEY = FlxKey.SHIFT;
  }

  /** 2D array of bools for connectors that are currently lit, listed as from,to */
  private var litArr : Array<Array<Bool>>;

  /** Colors that connectors are currently set to. Listed as from,to */
  private var colorArr : Array<Array<Color>>;

  /** Array of locations where this has a connector, as (from,to) */
  private var hasConnector : Array<Point>;

  /** The target angle to rotate to, in degrees */
  private var angleDelta : Float;

  /** True if this is currently rotating, false otherwise */
  public var isRotating(default, null) : Bool;

  /** Listener to call when this starts rotating. Arg is this PrismSprite */
  public var rotationStartListener(default, default) : PrismSprite -> Void;

  /** Listener to call when this stops rotating. Arg is this PrismSprite */
  public var rotationEndListener(default, default) : PrismSprite -> Void;

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

    angleDelta = 0;
    isRotating = false;
    rotationStartListener = null;
    rotationEndListener = null;

    //Interaction
    mouseReleasedCallback = onMouseRelease;
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

  /** Returns the current orientation. Result is only dependable when this isn't currently rotating */
  public inline function getOrientation() : Int {
    return Std.int(-angle/ROTATION_DISTANCE).mod(Util.HEX_SIDES);
  }

  /** Helper that corrects for the current orientation of the Prism.
   * Corrects for accessing the given side. Should be called whenever accessing an aribtrary
   * side of the Prism. Also mods to always be in range, in case of negatives or OOB.
   **/
  public inline function correctForOrientation(side : Int) : Int {
    return (getOrientation() + side).mod(Util.HEX_SIDES);
  }

  public override function draw() : Void {
    super.draw();
    for(p in hasConnector) {
      connectorSprites[p.row][p.col].color = ColorUtil.toFlxColor(colorArr[p.row][p.col], litArr[p.row][p.col]);
      stamp(connectorSprites[p.row][p.col],0,0);
    }
  }

  public override function update(dt : Float) {
    super.update(dt);

    //Check resulting rotation state
    if (angleDelta > 0) {
      angleDelta -= ROTATION_INC;
      angle += ROTATION_INC;
    } else if (angleDelta < 0) {
      angleDelta += ROTATION_INC;
      angle -= ROTATION_INC;
    }
    if (angleDelta == 0 && isRotating) {
      isRotating = false;
      if (rotationEndListener != null) rotationEndListener(this);
    }
  }

  private function onMouseRelease(f : FlxExtendedSprite, x : Int, y : Int) : Void {
    var h = getHitbox();
    var p = FlxG.mouse.getPosition();
    //Extra check that the mouse is still there
    if (h.containsPoint(p)){
      if (FlxG.keys.checkStatus(REVERSE_KEY, FlxInputState.PRESSED)) {
        angleDelta -= ROTATION_DISTANCE;
      } else {
        angleDelta += ROTATION_DISTANCE;
      }
      if (! isRotating) {
        isRotating = true;
        if (rotationStartListener != null) rotationStartListener(this);
      }
    }
    h.put();
    p.put();
  }

}

/** Can't delete this without crashing, not sure why... */
class UNUSED {}
