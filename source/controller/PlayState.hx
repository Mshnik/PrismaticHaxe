package controller;


import model.*;
import view.*;
import common.*;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  private static inline var BOARD_MARGIN_VERT = 20;
  private static inline var BOARD_MARGIN_HORIZ = 50;

  private var rows : Int = 6;
  private var cols : Int = 6;

  private var boardModel : Board;
  private var boardView : BoardView;

  /** True when the model has changed, next update loop should update the view */
  private var viewNeedsSync : Bool;

  override public function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.CYAN);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    boardModel = new Board(rows,cols);
    boardView = new BoardView(rows,cols);
    viewNeedsSync = false;
    add(boardView.spriteGroup);

    populate();

    boardView.spriteGroup.setPosition(BOARD_MARGIN_HORIZ, BOARD_MARGIN_VERT);
  }

  /** Helper function that adds a Source at the given location. For use during construction */
  private inline function addSource(r : Int, c : Int) {
    boardModel.set(r,c,new Source());
    var sprite = boardView.set(r,c,new SourceSprite()).asSourceSprite();
    sprite.colorSwitchListener = onSourceClick;
  }

  /** Helper function that adds an available color to the Source at the given location.
   * For use during construction.
   **/
  private inline function addColorToSource(row : Int, col : Int, c : Color) {
    if (boardModel.get(row,col).asSource().getCurrentColor() == Color.NONE) {
      boardView.get(row,col).asSourceSprite().litColor = c;
    }
    boardModel.get(row,col).asSource().addColor(c);
  }

  /** Helper function that adds a Prism at the given location. For use during construction */
  private inline function addPrism(r : Int, c : Int) {
    boardModel.set(r,c,new Prism());
    var sprite = boardView.set(r,c,new PrismSprite()).asPrismSprite();
    sprite.rotationStartListener = onPrismStartRotate;
    sprite.rotationEndListener = onPrismEndRotate;
  }

  /** Helper function that adds a connector to the Prism at the location.
   * For use during construction
   **/
  private inline function addConnectorToPrism(row : Int, col : Int, from : Int, to : Int,
                                              c : Color, biDirectional : Bool = true) {
    boardModel.get(row,col).asPrism().addConnector(from, to, c);
    if (biDirectional) {
      boardModel.get(row,col).asPrism().addConnector(to, from, c);
    }
    boardView.get(row,col).asPrismSprite().addConnection(c, from, to, biDirectional);
  }

  public function populate() {
    addSource(0,0);
    addColorToSource(0,0,Color.RED);
    addColorToSource(0,0,Color.BLUE);

    addPrism(0,1);
    addConnectorToPrism(0,1,5,0,Color.BLUE, true);
  }

  /** Helper function for PrismSprite starting rotation callback */
  private function onPrismStartRotate(h : PrismSprite) {
    //trace(h.position + " Started rotation");
    var m : Hex = boardModel.getAt(h.position);
    m.acceptConnections = false;
    boardModel.relight();
    viewNeedsSync = true;
  }

  /** Helper function for PrismSprite ending rotation callback */
  private function onPrismEndRotate(h : PrismSprite) {
    //trace("Ended rotation on orientation " + h.getOrientation());
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();
    m.acceptConnections = true;
    boardModel.relight();
    viewNeedsSync = true;
  }

  /** Helper function for when a Source is clicked. Cycles to next/previous color */
  private function onSourceClick(sprite : SourceSprite) {
    var s : Source = boardModel.getAt(sprite.position).asSource();
    if (HexSprite.CHECK_FOR_REVERSE()) {
      s.usePreviousColor();
    } else {
      s.useNextColor();
    }
    boardModel.relight();
    viewNeedsSync = true;
    sprite.litColor = s.getCurrentColor();
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    if(viewNeedsSync) {
      viewNeedsSync = false;
      boardView.spriteGroup.forEachOfType(PrismSprite, updatePrismSpriteLightings);
    }
  }

  /** Updates the lighting of the given PrismSprite to match its prism model */
  private function updatePrismSpriteLightings(sprite : PrismSprite) {
    var model : Prism = boardModel.getAt(sprite.position).asPrism();
    trace("");
    for(p in model.getConnectionLocations()) {
      var lit = model.isConnectorLit(p.row, p.col);
      trace(p + " - " + lit);
      if (p.col >= p.row || model.getConnector(p.row,p.col).baseColor != model.getConnector(p.col,p.row).baseColor) {
        sprite.setLighting(p.row, p.col, lit);
      }
    }
  }
}
