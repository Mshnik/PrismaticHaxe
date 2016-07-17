package;

import flixel.text.FlxText;
import game.Board;
import view.BoardView;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  private var boardModel : Board;
  private var boardView : BoardView;

  //Temp test stuff
  private var h : HexSprite;
  private var t : FlxText;

  override public function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.CYAN);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    boardModel = new Board(5,5);
    boardView = new BoardView(5,5);

    populate();
  }

  public function populate() {
    h = new HexSprite(200,200);
    h.rotationStartListener = function() { trace("Started rotation");};
    h.rotationEndListener = function(x : Int) { trace("Ended rotation on orientation " + x);};


    t = new FlxText(100,100);

    add(h);
    add(t);
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    t.text = Std.string(h.getOrientation());
  }
}
