package view;
import flixel.math.FlxPoint;
import view.HexSprite;
import common.Util;
import common.Point;
import common.Array2D;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using common.IntExtender;

class BoardView extends Array2D<HexSprite> {

  public static function initRowAndColDimens() {
    ROW_HEIGHT = 2 * HexSprite.HEX_SIDE_LENGTH;
    COL_WIDTH = Util.ROOT3 * HexSprite.HEX_SIDE_LENGTH;
  }

  /** Graphic height of a row of hexes. Amount to shift when a row moves. */
  public static var ROW_HEIGHT(default, null) : Float;

  /** Graphic width of a col of hexes. Amount to shift when a col moves. */
  public static var COL_WIDTH(default, null) : Float;

  private var hideTilesUntilLit : Bool;
  public var sourceLitMap(default, null) : Map<Point, Bool>;
  public var vertMargin(default, set) : Float;
  public var horizMargin(default, set) : Float;
  @final public var spriteGroup(default, null) : FlxTypedSpriteGroup<HexSprite>;

  public function new(rows : Int = 0, cols : Int = 0, hideTilesUntilLit : Bool = false) {
    super(rows, cols);

    this.hideTilesUntilLit = hideTilesUntilLit;
    sourceLitMap = new Map<Point, Bool>();
    spriteGroup = new FlxTypedSpriteGroup<HexSprite>();

    vertMargin = 0;
    horizMargin = 0;
  }

  /** Helper function for setting position of a HexSprite based on its row,col position */
  public inline function setGraphicPosition(h : HexSprite) {
    if (h != null) {
      if (h.rotator == null) {
        h.y = (h.position.row + h.position.col.mod(2)/2) * ROW_HEIGHT + vertMargin - h.height/2;
        h.x = h.position.col * COL_WIDTH + horizMargin - h.width/2;
      } else {
        var startAngle = Util.degToRad(h.rotator.position.angleTo(h.position));
        var rotatorAngleDelta = Util.degToRad((h.rotator.angle % 360)
        + ( (h.rotator.orientationAtRotationStart-1.5) * RotatableHexSprite.ROTATION_DISTANCE));

        var angle = startAngle + rotatorAngleDelta;

        h.y = h.rotator.y + (Math.sin(angle) * ROW_HEIGHT) + (h.rotator.height - h.height)/2;
        h.x = h.rotator.x + (Math.cos(angle) * ROW_HEIGHT) + (h.rotator.width - h.width)/2;
      }
    }
  }

  /** Returns the x/y graphic point of the center of the given row/col position */
  public inline function getGraphicPoisitionFromPoint(p : Point) : FlxPoint {
    return FlxPoint.weak(p.col * COL_WIDTH + horizMargin, (p.row + p.col.mod(2)/2) * ROW_HEIGHT + vertMargin);
  }

  /** Returns the row/col position of the given x/y mouse point. Useful for locating a hex position */
  public inline function getPointFromGraphicPosition(pt : FlxPoint) : Point {
    var col : Int = Std.int((pt.x - horizMargin)/COL_WIDTH + (pt.x > horizMargin ? 0.5 : -0.5));
    var row : Int = Std.int((pt.y - vertMargin)/ROW_HEIGHT - col.mod(2)/2 + (pt.y > vertMargin ? 0.5 : -0.5));
    pt.putWeak();
    return Point.get(row, col);
  }

  public function set_vertMargin(margin : Float) : Float {
    for(h in this) {
      h.y += (margin - vertMargin);
    }
    return vertMargin = margin;
  }

  public function set_horizMargin(margin : Float) : Float {
    for(h in this) {
      h.x += (margin - horizMargin);
    }
    return horizMargin = margin;
  }

  /** Helper function for setting position of a HexSprite based on its row,col position */
  private inline function setGraphicPositionAt(p : Point) {
    setGraphicPosition(getAt(p));
  }

  /** Overridden to narrow return type */
  public override function ensureSize(rows : Int, cols : Int) : BoardView {
    super.ensureSize(rows, cols);
    return this;
  }

  /** In addition to shifting array, shifts everything down by one row */
  public override function addRowTop() : BoardView {
    super.addRowTop();
    spriteGroup.forEach(setGraphicPosition);
    return this;
  }

  /** Overridden to narrow return type */
  public override function addRowBottom() : BoardView {
    super.addRowBottom();
    return this;
  }

  /** In addition to shifting array, shifts everything right by one column */
  public override function addColLeft() : BoardView {
    super.addColLeft();
    spriteGroup.forEach(setGraphicPosition);
    return this;
  }

  /** Overridden to narrow return type */
  public override function addColRight() : BoardView {
    super.addColRight();
    return this;
  }

  /** Returns the T at the given row,col. If safe, returns null if OOB */
  public override function get(row : Int, col : Int, safe : Bool = false) : HexSprite {
    return super.get(row, col, safe);
  }

  /** Returns the T at the given point */
  public override function getAt(p : Point, safe : Bool = false) : HexSprite {
    return super.getAt(p, safe);
  }

  /** One arg version of above for mapping */
  public inline function getAtUnsafe(p : Point) : HexSprite {
    return getAt(p, false);
  }

  /** One arg safe version of above for mapping */
  public inline function getAtSafe(p : Point) : HexSprite {
    return getAt(p, true);
  }

  /** In addition to setting element, removes old element from group,
   *   adds and sets position of Source element
   **/
  public override function set(row : Int, col : Int, h : HexSprite) : HexSprite {
    var oldH = get(row,col);
    if (oldH != null) {
      spriteGroup.remove(oldH);
      sourceLitMap.remove(oldH.position);
      oldH.isHidden = false;
    }
    super.set(row,col,h);
    if (h != null) {
      spriteGroup.add(h);
      h.isHidden = hideTilesUntilLit;
      if (h.isSourceSprite()) {
        sourceLitMap[h.position] = !h.isHidden;
      }
      setGraphicPosition(h);
    }
    return h;
  }

  /** In addition to removing the element, removes from group
   **/
  public override function remove(row : Int, col : Int) : HexSprite {
    var oldH = get(row,col);
    if (oldH != null) {
      spriteGroup.remove(oldH);
      oldH.isHidden = false;
    }
    return super.remove(row,col);
  }

  /** In addition to swapping the elements, makes sure their graphic positions stay up to date
   * and they stay in the group
   **/
  public override function swap(p1 : Point, p2 : Point) : BoardView {
    var h1 = getAt(p1);
    var h1WasHidden = h1 != null && h1.isHidden;
    var h2 = getAt(p2);
    var h2WasHidden = h2 != null && h2.isHidden;
    if (h1 != null) sourceLitMap.remove(h1.position);
    if (h2 != null) sourceLitMap.remove(h2.position);

    super.swap(p1,p2);

    if (h1 != null) {
      setGraphicPosition(spriteGroup.add(h1));
      h1.isHidden = h1WasHidden;
      if (h1.isSourceSprite()) {
        sourceLitMap[h1.position] = !h1.isHidden;
      }
    }
    if (h2 != null) {
      setGraphicPosition(spriteGroup.add(h2));
      h2.isHidden = h2WasHidden;
      if (h2.isSourceSprite()) {
        sourceLitMap[h2.position] = !h2.isHidden;
      }
    }

    return this;
  }

  /** Overridden to narrow return type */
  public override function swapManyForward(locations : Array<Point>) : BoardView {
    super.swapManyForward(locations);

    for(p in locations) {
      if (getAt(p) != null) {
        setGraphicPosition(getAt(p));
      }
    }

    return this;
  }

  /** Overridden to narrow return type */
  public override function swapManyBackward(locations : Array<Point>) : BoardView {
    super.swapManyBackward(locations);

    for(p in locations) {
      if (getAt(p) != null) {
        setGraphicPosition(getAt(p));
      }
    }

    return this;
  }

  /** In addition to shifting the array, makes sure their graphic positions stay up to date */
  public override function shift(dRow : Int, dCol : Int) : BoardView {
    super.shift(dRow, dCol);
    spriteGroup.forEach(setGraphicPosition);
    return this;
  }

  /** Overridden to narrow return type */
  public inline override function fillWith(elmCreator : Void->HexSprite) : BoardView {
    super.fillWith(elmCreator);
    return this;
  }

}
