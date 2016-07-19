package view;
import common.Util;
import common.Point;
import view.HexSprite;
import common.Array2D;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class BoardView extends Array2D<HexSprite> {

  /** Graphic height of a row of hexes. Amount to shift when a row moves. */
  private static inline var ROW_HEIGHT = 103 * HexSprite.SCALE;

  /** Graphic width of a col of hexes. Amount to shift when a col moves. */
  private static inline var COL_WIDTH = 91 * HexSprite.SCALE;

  @final public var spriteGroup(default, null) : FlxTypedSpriteGroup<HexSprite>;

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);

    spriteGroup = new FlxTypedSpriteGroup<HexSprite>();
  }

  /** Helper function for setting position of a HexSprite based on its row,col position */
  private static inline function setGraphicPosition(h : HexSprite) {
    if (h != null) {
      h.y = (h.position.row + Util.mod(h.position.col,2)/2) * ROW_HEIGHT;
      h.x = h.position.col * COL_WIDTH;
    }
  }

  /** Helper function for setting position of a HexSprite based on its row,col position */
  private inline function setGraphicPositionAt(p : Point) {
    setGraphicPosition(getAt(p));
  }

  /** Overridden to narrow return type */
  public inline override function ensureSize(rows : Int, cols : Int) : BoardView {
    super.ensureSize(rows, cols);
    return this;
  }

  /** In addition to shifting array, shifts everything down by one row */
  public override function addRowTop() {
    super.addRowTop();
    spriteGroup.forEach(setGraphicPosition);
  }

  /** In addition to shifting array, shifts everything right by one column */
  public override function addColLeft() {
    super.addColLeft();
    spriteGroup.forEach(setGraphicPosition);
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
    spriteGroup.add(h);
    setGraphicPosition(h);
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
  public override function swap(p1 : Point, p2 : Point) : Void {
    super.swap(p1,p2);
    setGraphicPosition(spriteGroup.add(getAt(p1)));
    setGraphicPosition(spriteGroup.add(getAt(p2)));
  }

  /** In addition to shifting the array, makes sure their graphic positions stay up to date */
  public override function shift(dRow : Int, dCol : Int) : Void {
    super.shift(dRow, dCol);
    spriteGroup.forEach(setGraphicPosition);
  }

  /** Overridden to narrow return type */
  public inline override function fillWith(elmCreator : Void->HexSprite) : BoardView {
    super.fillWith(elmCreator);
    return this;
  }
}
