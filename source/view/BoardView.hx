package view;
import view.HexSprite;
import common.Util;
import common.Point;
import common.Array2D;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using common.IntExtender;

class BoardView extends Array2D<HexSprite> {

  /** Graphic height of a row of hexes. Amount to shift when a row moves. */
  private static var ROW_HEIGHT = 2 * HexSprite.HEX_SIDE_LENGTH;

  /** Graphic width of a col of hexes. Amount to shift when a col moves. */
  private static var COL_WIDTH = Util.ROOT3 * HexSprite.HEX_SIDE_LENGTH;

  @final public var spriteGroup(default, null) : FlxTypedSpriteGroup<HexSprite>;

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);

    spriteGroup = new FlxTypedSpriteGroup<HexSprite>();
  }

  /** Helper function for setting position of a HexSprite based on its row,col position */
  public static inline function setGraphicPosition(h : HexSprite) {
    if (h != null) {
      if (h.rotator == null) {
        h.y = (h.position.row + h.position.col.mod(2)/2) * ROW_HEIGHT;
        h.x = h.position.col * COL_WIDTH;
      } else {
        var startAngle = Util.degToRad(h.rotator.position.angleTo(h.position));
        var rotatorAngleDelta = Util.degToRad((h.rotator.angle % 360)
        + ( (h.rotator.orientationAtRotationStart-1.5) * RotatableHexSprite.ROTATION_DISTANCE));

        var angle = startAngle + rotatorAngleDelta;

        h.y = h.rotator.y + (Math.sin(angle) * ROW_HEIGHT);
        h.x = h.rotator.x + (Math.cos(angle) * ROW_HEIGHT);
      }
    }
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
    }
    super.set(row,col,h);
    if (h != null) {
      spriteGroup.add(h);
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
    }
    return super.remove(row,col);
  }

  /** In addition to swapping the elements, makes sure their graphic positions stay up to date
   * and they stay in the group
   **/
  public override function swap(p1 : Point, p2 : Point) : BoardView {
    super.swap(p1,p2);

    var h1 = getAt(p1);
    if (h1 != null) {
      setGraphicPosition(spriteGroup.add(h1));
    }
    var h2 = getAt(p2);
    if (h2 != null) {
      setGraphicPosition(spriteGroup.add(h2));
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
