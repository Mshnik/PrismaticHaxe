package view;
import view.HexSprite;
import common.Array2D;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class BoardView extends Array2D<HexSprite> {

  /** Graphic height of a row of hexes. Amount to shift when a row moves. */
  private static inline var ROW_HEIGHT = 50;

  /** Graphic width of a col of hexes. Amount to shift when a col moves. */
  private static inline var COL_WIDTH = 50;

  private var spriteGroup : FlxTypedSpriteGroup<HexSprite>;

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);

    spriteGroup = new FlxTypedSpriteGroup<HexSprite>();
  }

  /** Helper for moving hexes down a row, graphically only. */
  private static function shiftHexDown(h : HexSprite) {
    h.y += ROW_HEIGHT;
  }

  /** Helper for moving hexes down a row, graphically only. */
  private static function shiftHexUp(h : HexSprite) {
    h.y -= ROW_HEIGHT;
  }

  /** Helper for moving hexes down a row, graphically only. */
  private static function shiftHexLeft(h : HexSprite) {
    h.x -= COL_WIDTH;
  }

  /** Helper for moving hexes down a row, graphically only. */
  private static function shiftHexRight(h : HexSprite) {
    h.x += COL_WIDTH;
  }


  /** In addition to shifting array, shifts everything down by one row */
  public override function addRowTop() {
    super.addRowTop();
    spriteGroup.forEach(shiftHexDown);
  }

  /** In addition to shifting array, shifts everything right by one column */
  public override function addColLeft() {
    super.addColLeft();
    spriteGroup.forEach(shiftHexRight);
  }



}
