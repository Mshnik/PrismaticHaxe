package model;

import common.Equitable.EquitableUtils;
import common.Positionable.Tile;
import common.*;

class Prism extends Hex {

  private var connectionArr : Array<Point>;
  private var connections : Array2D<ColorConnector>;

  public function new() {
    //Create fields first so overriden setters don't hit NPEs. Could add logic.. or just do this
    // "bad practice" lol... this is going to come back to bite me I'm sure
    connections = new Array2D<ColorConnector>().ensureSize(Util.HEX_SIDES, Util.HEX_SIDES);
    connectionArr = [];

    super();
  }

  /** Returns the list of locations that this has a connector */
  public inline function getConnectionLocations() : Array<Point> {
    return connectionArr.map(uncorrectPtForOrientation);
  }

  /** Returns true if there is a connection from,to, and it is lit */
  public inline function isConnectorLit(from : Int, to : Int) : Bool {
    var c =  getConnector(from, to);
    return c != null && c.isLit();
  }

  /** Returns the color connector (if any) from, to. Corrects for orientation */
  public inline function getConnector(from : Int, to : Int) : ColorConnector {
    return connections.get(correctForOrientation(from), correctForOrientation(to));
  }

  /** Returns a Array2D of the lit colors in this prism. */
  public inline function getLightingMatrix() : Array2D<Tile<Color>> {
    var arr2d = new Array2D<Tile<Color>>().ensureSize(Util.HEX_SIDES, Util.HEX_SIDES).fillWith(Tile.creator(Color.NONE));
    for(r in 0...Util.HEX_SIDES) {
      for(c in 0...Util.HEX_SIDES) {
        var con = getConnector(r,c);
        if (con != null) {
          arr2d.set(r,c,Tile.wrap(con.litColor));
        }
      }
    }
    return arr2d;
  }

  /**
   * Adds a color connector connecting from to to with the given base color
   * Overwrites any existing connector on from to to.
   * adds from,to to list to not have to search for connections.
   * Also resets lighting status, in case a connector is added in the middle of the game
   * (this is going to need to recalculate light anyways)
   * Returns a reference to this for chaining in construction
   **/
  public inline function addConnector(from : Int, to : Int, color : Color) : Prism {
    var p = Point.get(correctForOrientation(from), correctForOrientation(to));
    connections.set(p.row, p.col, new ColorConnector(color));
    connectionArr.remove(p); //Make sure no duplicates
    connectionArr.push(p);
    resetLight();
    return this;
  }

  /**
   * Adds light in on the targeted side of the given color.
   * Returns the array of sides of this Prism newly outputting color.
   * If the given side is already lit up a non-NONE color, does nothing (returns [])
   * If the color of light is acceptable but this connector or the destination side
   * is already lit up doesn't count that side in the returned array
   **/
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    var correctedSide = correctForOrientation(side);
    if (c == Color.NONE || lightIn[correctedSide] != Color.NONE) return [];

    lightIn[correctedSide] = c;

    var newLightOut : Array<Int> = [];
    for(to in 0...Util.HEX_SIDES) {
      var correctedTo = correctForOrientation(to);
      var connector : ColorConnector = connections.get(correctedSide, correctedTo);
      if (connector != null && connector.canAcceptColor(c)) {
        connector.litColor = c;
        if (! connector.isDeadEnd() && getLightOut(side) == Color.NONE) {
          lightOut[correctedTo] = c;
          newLightOut.push(correctForOrientation(to));
        }
      }
    }

    return newLightOut;
  }

  public override function resetLight() : Array<Int> {
    if (connections != null) {
      for (connector in connections) {
        connector.unlight();
      }
    }
    return super.resetLight();
  }

  public override function equals(h : Hex) : Bool {
    return super.equals(h) && h.isPrism()
      && connections.equalsUsing(h.asPrism().connections, EquitableUtils.equalsFunc(ColorConnector));
  }
}

/** Represents a connection from one side of a hex to another.
  * The position represents a (from,to) relationship in terms of sides of the prism.
  * Access of this should be corrected with correctForOrientation(..) before accessing.
  * Position being reflexive (i.e. (x,x)) means it is a dead end.
  * Base color is the color of the connector, and litColor is the collor it is currently lit
  **/
class ColorConnector implements Positionable {

  public var position(default, set) : Point;
  public var baseColor(default, null) : Color;
  public var litColor(default, set) : Color;

  public function new(base : Color) {
    position = Point.get(-1,-1);
    baseColor = base != null ? base : Color.NONE;
    litColor = Color.NONE;
  }

  public function toString() : String {
    return "(from,to = " + position + ", base = " + baseColor + ", currently " + litColor + ")";
  }

  public function set_position(p : Point) : Point {
    return position = p;
  }

  public function isDeadEnd() : Bool {
    return position.row == position.col;
  }

  public function unlight() {
    litColor = Color.NONE;
  }

  /** Returns true iff this is currently lit (not Color.NONE) */
  public inline function isLit() {
    return litColor != Color.NONE;
  }

  /** Returns true iff c can be accepted. This requires
   * - currently unlit
   * - c is compatable with baseColor
   **/
  public inline function canAcceptColor(c : Color) : Bool {
    return litColor == Color.NONE && ColorUtil.areCompatable(baseColor, c);
  }

  public function set_litColor(c : Color) : Color {
    if(c != Color.NONE && ! ColorUtil.areCompatable(baseColor, c)) {
      throw "Incompatable colors " + baseColor + " and " + c;
    }
    return litColor = c;
  }

  /** Two connectors are equal if they have the same position and the same base color */
  public function equals(c : ColorConnector) : Bool {
    return c != null && position.equals(c.position) && baseColor == c.baseColor;
  }
}
