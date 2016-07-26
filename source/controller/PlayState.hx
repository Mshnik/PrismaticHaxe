package controller;

import model.Prism;
import common.Util;
import common.Color;
import view.PrismSprite;
import model.Hex;
import model.Board;
import view.BoardView;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import view.HexSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  private static inline var BOARD_MARGIN_VERT = 20;
  private static inline var BOARD_MARGIN_HORIZ = 50;

  private var rows : Int = 6;
  private var cols : Int = 6;

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

  /** Helper function for HexSprite starting rotation callback */
  private function onStartRotate(h : HexSprite) {
    trace(h.position + " Started rotation");
    var m : Hex = boardModel.getAt(h.position);
    m.acceptConnections = false;
  }

  /** Helper function for HexSprite ending rotation callback */
  private function onEndRotate(h : HexSprite) {
    trace("Ended rotation on orientation " + h.getOrientation());
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();
    m.acceptConnections = true;
  }

  public function populate() {
    for(r in 0...rows) {
      for(c in 0...cols) {
        var m = boardModel.set(r,c,new Hex());
        var v = boardView.set(r,c,new PrismSprite()
          .addConnection(r %2 == 0 ? Color.RED : Color.BLUE, r,c)
          .addConnection(r % 2 == 0 ? Color.RED: Color.BLUE, r, (c+1)%Util.HEX_SIDES));
        v.rotationStartListener = onStartRotate;
        v.rotationEndListener = onEndRotate;
      }
    }
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);
  }

  private function updateLighting() : Void {
    for (r in 0...boardModel.getHeight()) {
      for(c in 0...boardView.getWidth()) {
        var h : Hex = boardModel.get(r,c);
        if (h != null) {
          if (h.isPrism()) {
            var prism : Prism = h.asPrism();
            for(p in prism.getConnectionLocations()) {
              boardView.get(r,c).asPrismSprite().setLighting(p.row, p.col, prism.isConnectorLit(r,c));
            }

          } else if (h.isSink()) {

          } else if (h.isSource()) {

          } else {
            throw "Illegal Hex created : " + h;
          }
        }
      }
    }
  }
}
