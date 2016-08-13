package controller;

import input.InputSettings;
import model.*;
import view.*;
import common.*;
import controller.util.LevelUtils;
import controller.util.InputThrottler;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;

using common.CollectionExtender;

class PlayState extends FlxState {

  /** The file this PlayState is loaded from. This should be set before create() is called. */
  public var sourceFile(default, default) : String;

  /** True if this is exploration mode, false for original puzzle mode */
  public var hideTilesUntilLit(default, default) : Bool;

  /** Constructor to set the few pre-create() fields */
  public function new(sourceFile : Dynamic, hideTilesUntilLit : Bool) {
    super();
    this.sourceFile = Std.string(sourceFile);
    this.hideTilesUntilLit = hideTilesUntilLit;
  }

  /**
   *
   *
   *  State Vars
   *
   *
   **/
  private static inline var INITIAL_BOARD_MARGIN_VERT = 90;
  private static inline var INITIAL_BOARD_MARGIN_HORIZ = 90;
  private static inline var BOARD_SCROLL_DELTA = 30;
  private var boardModel : Board;
  private var boardView : BoardView;
  private var hud : HUDView;
  private var hasWon : Bool; //True after this person has won
  private var viewNeedsSync : Bool; //True when the model has changed, next update loop should update the view
  private var rotatingSprites : Array<RotatableHexSprite>; //All current rotating sprites
  private var currentRotator : RotatorSprite; //Rotator currently rotating hexes

  /**
   *
   *
   * Input/Controls Vars
   *
   *
   **/
  private var inputThrottlers : Array<InputThrottler>;
  private static var MOUSE_SCROLL_BOX_SIZE = 20;

  /**
   *
   *
   * Pause and Menu Vars
   *
   *
   **/
  private static var PAUSE_MENU_BASE_TINT : Int = 0x99000000;

  /** Helper function to make sure visuals are ready to go. Has to be here, not in Main. IDK why. */
  public static inline function prepForVisuals() {
    PrismSprite.initGeometry();
  }

  /** Create function called when this state is created by inner Flixel logic */
  public override function create() : Void {
    super.create();

    //Set fields
    rotatingSprites = [];
    viewNeedsSync = true;
    currentRotator = null;
    hasWon = false;

    //Load board from sourceFile
    loadFromFile();

    //Add background
    var bg = new FlxSprite();
    bg.loadGraphic(AssetPaths.main_bg__jpg);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    //Tweak and add board view
    boardView.vertMargin = INITIAL_BOARD_MARGIN_VERT;
    boardView.horizMargin = INITIAL_BOARD_MARGIN_HORIZ;
    add(boardView.spriteGroup);

    //Add HUD and other menus
    hud = new HUDView(pause,LevelUtils.getLevelName(sourceFile));
    add(hud);

    //Set up Input
    inputThrottlers = [];
    inputThrottlers.push(InputThrottler.onKey(InputSettings.LEFT, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputSettings.RIGHT, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputSettings.DOWN, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputSettings.UP, arrowKeyPressed, InputThrottler.EVERY_FRAME));

//    mouseScrollRight = InputThrottler.onMouseInRect(FlxRect.get(0,0,MOUSE_SCROLL_BOX_SIZE,FlxG.height),
//                                                    function() {shiftView(Point.LEFT);},
//                                                    InputThrottler.SLOW_DECAY);
//    mouseScrollLeft = InputThrottler.onMouseInRect(FlxRect.get(FlxG.width-MOUSE_SCROLL_BOX_SIZE,0,MOUSE_SCROLL_BOX_SIZE,FlxG.height),
//                                                   function() {shiftView(Point.RIGHT);},
//                                                   InputThrottler.SLOW_DECAY);
//    mouseScrollUp = InputThrottler.onMouseInRect(FlxRect.get(0,FlxG.height-MOUSE_SCROLL_BOX_SIZE,FlxG.width,MOUSE_SCROLL_BOX_SIZE),
//                                                 function() {shiftView(Point.DOWN);},
//                                                 InputThrottler.SLOW_DECAY);
//    mouseScrollDown = InputThrottler.onMouseInRect(FlxRect.get(0,0,FlxG.width,MOUSE_SCROLL_BOX_SIZE),
//                                                   function() {shiftView(Point.UP);},
//                                                   InputThrottler.SLOW_DECAY);

    //Misc prep
    prepForVisuals();
  }

  /** Reads this.sourceFile into memory. Also creates a boardView that matches the read model */
  private function loadFromFile() {
    boardModel = XMLParser.read(sourceFile);
    boardModel.disableOnRotate = true;

    //Create a view that matches the model
    boardView = new BoardView(boardModel.getHeight(), boardModel.getWidth(), hideTilesUntilLit);

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

  /** Helper function for when any sprites starts rotation callback. Called by more specific callbacks */
  private function onStartRotation(h : RotatableHexSprite) {
    if (! rotatingSprites.contains(h)){
      rotatingSprites.push(h);
    }
  }

  /** Helper function for when any sprites ends rotation callback. Called by more specific callbacks */
  private function onEndRotation(h : RotatableHexSprite) {
    rotatingSprites.remove(h);
    if (rotatingSprites.length == 0) {
      boardModel.resetNextConnectionGroupCounter();
    }
  }

  /** Helper function for PrismSprite starting rotation callback */
  private function onPrismStartRotation(h : RotatableHexSprite) {
    onStartRotation(h);
    if (h.rotator == null) {
      boardModel.setAsNextConnectionGroup([h.position]);
    }
    viewNeedsSync = true;
  }

  /** Helper function for PrismSprite ending rotation callback */
  private function onPrismEndRotation(h : RotatableHexSprite) {
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();
    if (h.rotator == null) {
      boardModel.resetToDefaultConnectionGroup([h.position]);
    }
    viewNeedsSync = true;
    onEndRotation(h);
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
    onStartRotation(h);
    h.asRotatorSprite().orientationAtRotationStart = h.getOrientation();

    var spriteLocations : Array<Point> = h.position.getNeighbors();
    for(sprite in spriteLocations.map(boardView.getAtSafe).filter(Util.isNonNull)) {
      h.asRotatorSprite().addSpriteToGroup(sprite);
      //Add to back of sprite group to move to the top (z-index)
      boardView.spriteGroup.remove(sprite, true);
      boardView.spriteGroup.add(sprite);
    }
    //Set as connection group so light only works within this group
    boardModel.setAsNextConnectionGroup(spriteLocations);
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

    var spriteLocations : Array<Point> = r.position.getNeighbors();
    var sprites = spriteLocations.map(boardView.getAtSafe).filter(Util.isNonNull);

    //Update model
    var m : Hex = boardModel.getAt(h.position);
    m.orientation = h.getOrientation();

    boardModel.resetToDefaultConnectionGroup(spriteLocations);

    for(sprite in sprites) {
      if (sprite.isPrismSprite()) {
        boardModel.getAt(sprite.position).orientation = sprite.asPrismSprite().getOrientation();
      }
    }

    viewNeedsSync = true;
    currentRotator = null;
    onEndRotation(h);
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
      if (hideTilesUntilLit) {
        boardView.spriteGroup.forEach(revealLitTiles);
      }
      hud.setGoalValues(score.get());
      if (score.isSatisfied()) {
        onVictory();
      }
    }

    for(inputThrottler in inputThrottlers) {
      inputThrottler.update(elapsed);
    }
  }

  /** Reveals tiles based on their lighting status */
  private inline function revealLitTiles(sprite : HexSprite) {
    var model : Hex = boardModel.getAt(sprite.position);
    if (model.hasLightIn || model.hasLightOut) {
      sprite.isHidden = false;
    }
  }

  /** Updates the lighting of the given PrismSprite to match its prism model */
  private inline function updatePrismSpriteLightings(sprite : PrismSprite) {
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
  private inline function updateSinkSpriteLighting(sprite : SinkSprite) {
    var model : Sink = boardModel.getAt(sprite.position).asSink();
    sprite.asSinkSprite().litColor = model.getCurrentColor();
  }

  private function arrowKeyPressed(keyCode : Int) {
    switch(keyCode) {
      case FlxKey.LEFT:   shiftView(Point.RIGHT);
      case FlxKey.RIGHT:  shiftView(Point.LEFT);
      case FlxKey.UP:     shiftView(Point.DOWN);
      case FlxKey.DOWN:   shiftView(Point.UP);
    }
  }

  /** Helper that shifts the boardView in the given direction */
  private inline function shiftView(direction : Point) {
    boardView.horizMargin += direction.col * BOARD_SCROLL_DELTA;
    boardView.vertMargin += direction.row * BOARD_SCROLL_DELTA;
  }

  /** Pauses the game, opening the pause state. The substate is not persistant, it will be destroyed on close */
  public function pause() {
    var pauseState:PauseState = new PauseState(PAUSE_MENU_BASE_TINT);
    openSubState(pauseState);
  }

  /** Called when the person wins for the first time this play state. */
  private function onVictory() {
    if (! hasWon) {
      hasWon = true;
      trace("You win!");
    }
  }

  /**
   * Destroy function called when this state is swapped away.
   * sourceFile left so it can be reloaded
   **/
  public override function destroy() {
    super.destroy();

    boardModel = null;
    boardView = null;
    hud = null;
    rotatingSprites = null;
    currentRotator = null;
    viewNeedsSync = false;
    hasWon = false;

    for(inputThrottler in inputThrottlers) {
      inputThrottler.destroy();
    }
    inputThrottlers = null;
  }
}
