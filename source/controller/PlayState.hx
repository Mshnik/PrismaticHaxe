package controller;

import model.Score;
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

  private static inline var BOARD_MARGIN_VERT = 40;
  private static inline var BOARD_MARGIN_HORIZ = 40;

  private var boardModel : Board;
  private var boardView : BoardView;
  private var hud : HUDView;

  private var rows : Int;
  private var cols : Int;

  /** True when the model has changed, next update loop should update the view */
  private var viewNeedsSync : Bool;

  /** Rotator currently rotating hexes */
  private var currentRotator : RotatorSprite;

  /** Sets the sourceFile to the given path, also creates an XMLParser around it. */
  public function set_sourceFile(path : Dynamic) : Dynamic {
    return sourceFile = path;
  }

  /** Helper function to make sure visuals are ready to go */
  public static inline function prepForVisuals() {
    PrismSprite.initGeometry();
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
    hud = new HUDView();
    loadFromFile();
    viewNeedsSync = true;
    currentRotator = null;

    boardView.vertMargin = BOARD_MARGIN_VERT;
    boardView.horizMargin = BOARD_MARGIN_HORIZ;
    add(boardView.spriteGroup);
    add(hud);

    prepForVisuals();
  }

  /** Reads this.sourceFile into memory. Also creates a boardView that matches the read model */
  private function loadFromFile() {
    boardModel = XMLParser.read(sourceFile);
    boardModel.disableOnRotate = true;

    //Create a view that matches the model
    boardView = new BoardView().ensureSize(boardModel.getHeight(), boardModel.getWidth());

    for(r in 0...boardModel.getHeight()) {
      for(c in 0...boardModel.getWidth()) {
        var h = boardModel.get(r,c);
        if (h != null) {
          if (h.isPrism()) {
            var prismSprite = new PrismSprite();
            var prismModel = h.asPrism();
            var orientation = prismModel.orientation;
            prismModel.orientation = 0;
            for (p in prismModel.getConnectionLocations()) {
              prismSprite.addConnection(prismModel.getConnector(p.row, p.col).baseColor, p.row, p.col);
            }
            prismModel.orientation = orientation;
            prismSprite.addRotation(orientation);
            prismSprite.rotationStartListener = onPrismStartRotation;
            prismSprite.rotationEndListener = onPrismEndRotation;
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
          else if (h.isRotator()){
            var rotatorSprite = new RotatorSprite();
            rotatorSprite.addRotation(h.orientation);
            rotatorSprite.rotationStartListener = onRotatorStartRotation;
            rotatorSprite.rotationEndListener = onRotatorEndRotation;
            rotatorSprite.rotationValidator = allowRotatorRotation;
            boardView.set(r,c,rotatorSprite);
          }
          else {
            trace("Illegal Hex created " + h);
          }
        }
      }
    }

    boardModel.disableOnRotate = false;
  }

  /** Helper function for PrismSprite starting rotation callback */
  private function onPrismStartRotation(h : RotatableHexSprite) {
    var m : Hex = boardModel.getAt(h.position);
    m.acceptConnections = false;
    viewNeedsSync = true;
  }

  /** Helper function for PrismSprite ending rotation callback */
  private function onPrismEndRotation(h : RotatableHexSprite) {
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

  /** Helper function for determining if a RotatorSprite is allowed to acknowledge a click */
  private function allowRotatorRotation(h : RotatableHexSprite) : Bool {
    return currentRotator == null || currentRotator == h;
  }

  /** Helper function for RotatorSprite starting rotation callback */
  private function onRotatorStartRotation(h : RotatableHexSprite) {
    h.asRotatorSprite().orientationAtRotationStart = h.getOrientation();

    for(sprite in h.asRotatorSprite().position.getNeighbors().map(boardView.getAtSafe).filter(Util.isNonNull)) {
      h.asRotatorSprite().addSpriteToGroup(sprite);
      boardModel.getAt(sprite.position).acceptConnections = false;
    }
    viewNeedsSync = true;
    currentRotator = h.asRotatorSprite();
  }

  /** Helper function for RotatorSprite ending rotation callback */
  private function onRotatorEndRotation(h : RotatableHexSprite) {
    var r = h.asRotatorSprite();
    h.asRotatorSprite().updateAngle();
    h.asRotatorSprite().clearSpriteGroup();

    //Move sprites in board
    var i : Int = r.orientationAtRotationStart;
    while(i < h.getOrientation()) {
      boardView.swapManyBackward(h.position.getNeighbors());
      i++;
    }
    while(i > h.getOrientation()) {
      boardView.swapManyForward(h.position.getNeighbors());
      i--;
    }

    var sprites = r.position.getNeighbors().map(boardView.getAtSafe).filter(Util.isNonNull);

    //Update model
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();

    for(sprite in sprites) {
      boardModel.getAt(sprite.position).acceptConnections = true;
      if (sprite.isPrismSprite()) {
        boardModel.getAt(sprite.position).orientation = sprite.asPrismSprite().getOrientation();
      }
    }

    viewNeedsSync = true;
    currentRotator = null;
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    if(currentRotator != null) {
      for(sprite in currentRotator.getSprites()) {
        boardView.setGraphicPosition(sprite);
      }
    }

    if(viewNeedsSync) {
      viewNeedsSync = false;
      var score : Score = boardModel.relight();
      boardView.spriteGroup.forEachOfType(PrismSprite, updatePrismSpriteLightings);
      boardView.spriteGroup.forEachOfType(SinkSprite, updateSinkSpriteLighting);
      hud.setGoalValues(score.get());
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
