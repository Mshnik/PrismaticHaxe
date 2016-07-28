package controller;

import openfl.Assets;
import model.*;
import view.*;
import common.*;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState {

  /** The file this PlayState is loaded from. This should be set before create() is called. */
  public var sourceFile(default, set) : Dynamic;

  /** The parser for the source file. Set whenever sourceFile is set */
  private var xmlParser : XMLParser;

  private static inline var BOARD_MARGIN_VERT = 20;
  private static inline var BOARD_MARGIN_HORIZ = 50;

  private var boardModel : Board;
  private var boardView : BoardView;

  private var rows : Int;
  private var cols : Int;

  /** True when the model has changed, next update loop should update the view */
  private var viewNeedsSync : Bool;

  /** Sets the sourceFile to the given path, also creates an XMLParser around it. */
  public function set_sourceFile(path : Dynamic) : Dynamic {
    xmlParser = new XMLParser(path);
    return sourceFile = path;
  }

  /** Create function called when this state is created by inner Flixel logic */
  public override function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.CYAN);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    sourceFile = AssetPaths.TEST__xml;
    loadFromFile();
    viewNeedsSync = true;

    boardView.spriteGroup.setPosition(BOARD_MARGIN_HORIZ, BOARD_MARGIN_VERT);
    add(boardView.spriteGroup);
  }

  /** Reads this.sourceFile into memory. Also creates a boardView that matches the read model */
  private function loadFromFile() {
    boardModel = xmlParser.getBoard();

    //Create a view that matches the model
    boardView = new BoardView().ensureSize(boardModel.getHeight(), boardModel.getWidth());

    for(r in 0...boardModel.getHeight()) {
      for(c in 0...boardModel.getWidth()) {
        var h = boardModel.get(r,c);
        if (h != null) {
          if (h.isPrism()) {
            var prismSprite = new PrismSprite();
            var prismModel = h.asPrism();
            for (p in prismModel.getConnectionLocations()) {
              prismSprite.addConnection(prismModel.getConnector(p.row, p.col).baseColor, p.row, p.col);
            }
            prismSprite.rotationStartListener = onStartRotation;
            prismSprite.rotationEndListener = onEndRotation;
            boardView.set(r,c,prismSprite);
          }
          else if (h.isSource()) {
            var sourceSprite = new SourceSprite();
            sourceSprite.litColor = h.asSource().getCurrentColor();
            sourceSprite.colorSwitchListener = onSourceClick;
            boardView.set(r,c,sourceSprite);
          }
          else if (h.isSink()) {
            boardView.set(r,c,new SinkSprite());
          }
          else {
            trace("Illegal Hex created " + h);
          }
        }
      }
    }
  }

  /** Helper function for RotatableHexSprite starting rotation callback */
  private function onStartRotation(h : RotatableHexSprite) {
    //trace(h.position + " Started rotation");
    var m : Hex = boardModel.getAt(h.position);
    m.acceptConnections = false;
    viewNeedsSync = true;
  }

  /** Helper function for RotatableHexSprite ending rotation callback */
  private function onEndRotation(h : RotatableHexSprite) {
    //trace("Ended rotation on orientation " + h.getOrientation());
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();
    m.acceptConnections = true;
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
    viewNeedsSync = true;
    sprite.litColor = s.getCurrentColor();
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    if(viewNeedsSync) {
      viewNeedsSync = false;
      boardModel.relight();
      boardView.spriteGroup.forEachOfType(PrismSprite, updatePrismSpriteLightings);
      boardView.spriteGroup.forEachOfType(SinkSprite, updateSinkSpriteLighting);
    }
  }

  /** Updates the lighting of the given PrismSprite to match its prism model */
  private function updatePrismSpriteLightings(sprite : PrismSprite) {
    var model : Prism = boardModel.getAt(sprite.position).asPrism();
    for(p in model.getConnectionLocations()) {
      var lit = model.isConnectorLit(p.row, p.col);
      if (!lit && model.getConnector(p.col, p.row) != null &&
            model.getConnector(p.row,p.col).baseColor == model.getConnector(p.col,p.row).baseColor) {
        lit = model.isConnectorLit(p.col, p.row);
      }
      sprite.setLighting(p.row, p.col, lit);
    }
  }

  /** Updates the lighting of the given SinkSprite to match its Sink model */
  private function updateSinkSpriteLighting(sprite : SinkSprite) {
    var model : Sink = boardModel.getAt(sprite.position).asSink();
    sprite.asSinkSprite().litColor = model.getCurrentColor();
  }

  /**
   * Destroy function called when this state is swapped away.
   * SourceFile and XML parser left so it can be reloaded
   **/
  public override function destroy() {
    super.destroy();

    boardModel = null;
    boardView = null;
    rows = -1;
    cols = -1;
    viewNeedsSync = false;
  }
}
