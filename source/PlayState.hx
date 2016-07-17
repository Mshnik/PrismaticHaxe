package;

import game.Hex;
import game.Board;
import view.BoardView;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  private static inline var BOARD_MARGIN_VERT = 20;
  private static inline var BOARD_MARGIN_HORIZ = 50;

  private var rows : Int = 5;
  private var cols : Int = 9;

  private var boardModel : Board;
  private var boardView : BoardView;

  override public function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.CYAN);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    boardModel = new Board(rows,cols);
    boardView = new BoardView(rows,cols);
    add(boardView.spriteGroup);

    populate();

    boardView.spriteGroup.setPosition(BOARD_MARGIN_HORIZ, BOARD_MARGIN_VERT);
  }

  public function populate() {
    for(r in 0...rows) {
      for(c in 0...cols) {
        var m = boardModel.set(r,c,new Hex());
        var v = boardView.set(r,c,new HexSprite());
        v.rotationStartListener = function(h : HexSprite) { trace(h.position + " Started rotation");};
        v.rotationEndListener = function(h : HexSprite) { trace("Ended rotation on orientation " + h.getOrientation());};
      }
    }
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);
  }
}
