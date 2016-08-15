package controller;

import view.EditorView.BoardAction;
import model.*;
import view.*;
import common.*;
import controller.util.LevelUtils;
import controller.util.InputThrottler;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;
import flixel.FlxState;

using common.CollectionExtender;

class PlayState extends FlxState {

  /** The game type of this PlayState, one of the above enum values */
  private var gameType : GameType;

  /** In classic, the file path to the board to load.
   * In exploration, the seed for board creation.
   * In edit, the file path to the board to load, and overwrite when this board is saved, but initially null.
   **/
  private var source(default, default) : String;

  /** Creates and returns a new PlayState for classic mode */
  public static inline function createClassic(source : String) : PlayState {
    var p : PlayState = new PlayState();
    p.gameType = GameType.CLASSIC;
    p.source = source;
    return p;
  }

  /** Creates and returns a new PlayState for edit mode */
  public static inline function createEdit() : PlayState {
    var p : PlayState = new PlayState();
    p.gameType = GameType.EDIT;
    p.source = null;
    return p;
  }

  /** Creates and returns a new PlayState for exploration mode. If seed not given (or null), uses random seed. */
  public static inline function createExploration(seed : Int = null) : PlayState {
    var p : PlayState = new PlayState();
    p.gameType = GameType.EXPLORATION;
    if (seed == null){
      seed = Std.int((1 << 30 - 1)*Math.random());
    }
    p.source = Std.string(seed);
    return p;
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
  private var hexHighlight : FlxSprite;
  private var mouseOOB : Bool; //True when the mouse is is hovering over the HUD or the Editor Toolbar
  private var boardView : BoardView;
  private var hud : HUDView;
  private var hasWon : Bool; //True after this person has won
  private var viewNeedsSync : Bool; //True when the model has changed, next update loop should update the view
  private var rotatingSprites : Array<RotatableHexSprite>; //All current rotating sprites
  private var currentRotator : RotatorSprite; //Rotator currently rotating hexes

  /**
   *
   *
   *  Level Editing Vars
   *  (only used in Edit)
   *
   *
   **/
  private var editor : EditorView;
  private var selectedPosition : Point;

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

  /** Sets all fields to default empty/null/false vals. If forStart, sets to state for new, else sets
   * to truly null.
   **/
  private inline function resetFields(forStart : Bool) : Void {
    boardModel = null;
    hexHighlight = null;
    mouseOOB = false;
    boardView = null;
    hud = null;
    hasWon = false;
    viewNeedsSync = forStart;
    rotatingSprites = forStart ? [] : null;
    currentRotator = null;

    editor = null;
    selectedPosition = forStart ? Point.get(-1,-1) : null;

    inputThrottlers = null;
  }

  /** Create function called when this state is created by inner Flixel logic */
  public override function create() : Void {
    super.create();

    resetFields(true);

    //Prep the board, depending on the game type
    switch(gameType) {
      case GameType.CLASSIC: prepBoardFromFile();
      case GameType.EXPLORATION: prepBoardFromSeed();
      case GameType.EDIT: prepEmptyBoard();
    }

    //Add background
    var bg = new FlxSprite();
    bg.loadGraphic(AssetPaths.main_bg__jpg);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    //Add the highlight here so it will be underneath the board
    hexHighlight = new FlxSprite().loadGraphic(AssetPaths.hex_highlight__png);
    add(hexHighlight);

    //Tweak and add board view
    boardView.vertMargin = INITIAL_BOARD_MARGIN_VERT;
    boardView.horizMargin = INITIAL_BOARD_MARGIN_HORIZ;
    add(boardView.spriteGroup);

    //Add HUD and other menus
    add(hud);
    if (gameType == GameType.EDIT) {
      add(editor);
    }

    //Set up Input
    inputThrottlers = [];
    inputThrottlers.push(InputThrottler.onKey(InputController.LEFT, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputController.RIGHT, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputController.DOWN, arrowKeyPressed, InputThrottler.EVERY_FRAME));
    inputThrottlers.push(InputThrottler.onKey(InputController.UP, arrowKeyPressed, InputThrottler.EVERY_FRAME));

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

  /** Helper function to make sure visuals are ready to go. Has to be here, not in Main. IDK why. */
  public static inline function prepForVisuals() {
    PrismSprite.initGeometry();
  }

  /** Helper function for initializing PrismSprites */
  private inline function prepPrismSprite(prismSprite : PrismSprite) : PrismSprite {
    prismSprite.rotationStartListener = onPrismStartRotation;
    prismSprite.rotationEndListener = onPrismEndRotation;
    prismSprite.rotationValidator = allowRotation;
    return prismSprite;
  }

  /** Helper function for initializing SourceSprites */
  private inline function prepSourceSprite(sourceSprite : SourceSprite) : SourceSprite {
    sourceSprite.colorSwitchListener = onSourceClick;
    sourceSprite.colorSwitchValidator = allowSourceClick;
    return sourceSprite;
  }

  /** Helper function for initializing SinkSprites */
  private inline function prepSinkSprite(sinkSprite : SinkSprite) : SinkSprite {
    return sinkSprite;
  }

  /** Helper function for initializing RotatorSprites */
  private inline function prepRotatorSprite(rotatorSprite : RotatorSprite) : RotatorSprite {
    rotatorSprite.rotationStartListener = onRotatorStartRotation;
    rotatorSprite.rotationEndListener = onRotatorEndRotation;
    rotatorSprite.rotationValidator = allowRotation;
    return rotatorSprite;
  }

  /** Reads this.source into memory. Also creates a boardView that matches the read model.
   **/
  private inline function prepBoardFromFile() {
    if (gameType == GameType.EXPLORATION) throw "Can't read board from file in Exploration mode";

    boardModel = XMLParser.read(source);
    boardModel.disableOnRotate = true;

    //Create a view that matches the model
    boardView = new BoardView(boardModel.getHeight(), boardModel.getWidth(), false);

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
            prepPrismSprite(prismSprite);
            boardView.set(r,c,prismSprite);
          }
          else if (h.isSource()) {
            var sourceSprite = new SourceSprite();
            sourceSprite.litColor = h.asSource().getCurrentColor();
            prepSourceSprite(sourceSprite);
            boardView.set(r,c,sourceSprite);
          }
          else if (h.isSink()) {
            var sinkSprite = new SinkSprite();
            prepSinkSprite(sinkSprite);
            boardView.set(r,c,sinkSprite);
          }
          else if (h.isRotator()){
            var rotatorSprite = new RotatorSprite();
            rotatorSprite.addRotation(h.orientation);
            prepRotatorSprite(rotatorSprite);
            boardView.set(r,c,rotatorSprite);
          }
          else {
            trace("Illegal Hex created " + h);
          }
        }
      }
    }

    boardModel.disableOnRotate = false;

    hud = new HUDView(gameType).withPauseHandler(pause).withLevelName(LevelUtils.getLevelName(source));
  }

  /** Creates a new exploration board from the seed */
  private inline function prepBoardFromSeed() {
    if (gameType != GameType.EXPLORATION) throw "Can't generate board from seed if not in Exploration mode";


    hud = new HUDView(gameType).withPauseHandler(pause);
  }

  /** Creates a new empty board */
  private inline function prepEmptyBoard() {
    if (gameType != GameType.EDIT) throw "Can't prep empty board from seed if not in Edit mode";

    boardModel = new Board();
    boardView = new BoardView();

    hud = new HUDView(gameType).withPauseHandler(pause)
                               .withLevelNameChangedHandler(setLevelName)
                               .withGoalChangedHandler(setGoal);
    editor = new EditorView().withCreateHandlers(
      function(){createAndAddHex(selectedPosition, HexType.PRISM);},
      function(){createAndAddHex(selectedPosition, HexType.SOURCE);},
      function(){createAndAddHex(selectedPosition, HexType.SINK);},
      function(){createAndAddHex(selectedPosition, HexType.ROTATOR);},
      shouldShowRotatorCreateButton)
    .withMouseValidHandler(function(){return !mouseOOB;})
    .withEditHandlers(
      function(){return selectedPosition != null && boardModel.getAt(selectedPosition, true) != null;},
      function(){return boardModel.getAt(selectedPosition).hexType;})
    .withSourceEditingHandler(
      function(){return boardModel.getAt(selectedPosition).asSource().getAvailableColors();},
      function(str : String, b : Bool){return setColorOnSource(selectedPosition, Type.createEnum(Color, str), b);})
    .withDeleteHandler(function(){deleteHex(selectedPosition);});
  }

  /** Pauses the game, opening the pause state. The substate is not persistant, it will be destroyed on close */
  private function pause() : Void {
    var pauseState:PauseState = new PauseState(PAUSE_MENU_BASE_TINT);
    openSubState(pauseState);
  }

  /** Helper function for determining if a Sprite is allowed to acknowledge a rotation click */
  private function allowRotation(h : RotatableHexSprite) : Bool {
    var rotationOK = currentRotator == null || !h.isRotatorSprite() || currentRotator == h;
    return rotationOK && (gameType == GameType.EDIT && editor.action == BoardAction.PLAY || gameType != GameType.EDIT);
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

  /** Helper function for validation when a Source is clicked. */
  private function allowSourceClick(sprite : SourceSprite) : Bool {
    return gameType != GameType.EDIT || (gameType == GameType.EDIT && editor.action == BoardAction.PLAY);
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

    //Check for editing hotkeys
    if (editor != null) {
      //Check Back (Esc) for menu dismissal
      if (InputController.CHECK_BACK()) {
        editor.goBack();
      }

      //Check for action quickselect
      if (InputController.CHECK_MODE_PLAY()) {
        editor.action = BoardAction.PLAY;
      } else if (InputController.CHECK_MODE_CREATE()) {
        editor.action = BoardAction.CREATE;
      } else if (InputController.CHECK_MODE_EDIT()) {
        editor.action = BoardAction.EDIT;
      } else if (InputController.CHECK_MODE_MOVE()) {
        editor.action = BoardAction.MOVE;
      } else if (InputController.CHECK_MODE_DELETE()) {
        editor.action = BoardAction.DELETE;
      }
    }

    //Update Highlight
    if (editor == null || ! editor.highlightLocked){
      //Check mouseOOB
      mouseOOB = hud.mousePresent() || editor != null && editor.mousePresent();

      if (mouseOOB) {
        selectedPosition = null;
        hexHighlight.setPosition(-hexHighlight.width, -hexHighlight.height);
      } else {
        selectedPosition = boardView.getPointFromGraphicPosition(FlxG.mouse.getPosition(FlxPoint.weak()));
        var h = boardView.getAt(selectedPosition,true);
        hexHighlight.angle = h != null ? h.angle : 0;
        var pt = boardView.getGraphicPoisitionFromPoint(selectedPosition);
        hexHighlight.setPosition(pt.x - hexHighlight.width/2, pt.y-hexHighlight.height/2);
        pt.putWeak();
      }
    }

    //Update graphic positions of hexes being rotated
    if(currentRotator != null) {
      for(sprite in currentRotator.getSprites()) {
        boardView.setGraphicPosition(sprite);
      }
    }

    //Check for view sync, if needed perform that
    if(viewNeedsSync) {
      viewNeedsSync = false;
      var score : Score = boardModel.relight();
      boardView.spriteGroup.forEachOfType(PrismSprite, updatePrismSpriteLightings);
      boardView.spriteGroup.forEachOfType(SinkSprite, updateSinkSpriteLighting);
      if (gameType == GameType.EXPLORATION) {
        boardView.spriteGroup.forEach(revealLitTiles);
      }
      hud.setGoalValues(score.get());
      if (gameType == GameType.CLASSIC && score.isSatisfied()) {
        onVictory();
      }
    }

    //Update inputs
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

  /** Called when the person wins for the first time this play state. */
  private function onVictory() {
    if (! hasWon) {
      hasWon = true;
      trace("You win!");
    }
  }

  /******************************************************************************************************
  *
  *
  *
  *
  *
  *
  *  LEVEL EDITING
  *
  *
  *
  *
  *
  *
  ******************************************************************************************************/

  /** Sets the name of the current level. If the operation was enter, writes the board to file. */
  private function setLevelName(name : String, operation : String) : Void {
    source = LevelSelectState.DATA_PATH + name;
    #if !flash
    if (operation == "enter") {
      XMLParser.write(source, boardModel);
      trace("Board written to mem at " + source);
    }
    #end
  }

  /** Sets the goal of the current level. */
  private function setGoal(color : Color, goal : Int) : Void {
    boardModel.getScore().setGoal(color, goal);
    trace(color + " Goal updated");
  }

  /** Returns true if the create rotator button should be shown for the current selected position.
   * Checks all neighbor locations, to make sure no rotator is present.
   **/
  private inline function shouldShowRotatorCreateButton() : Bool {
    return selectedPosition.getNeighbors().map(boardModel.getAtSafe)
            .filter(function(h : Hex){return h != null && h.isRotator();})
            .length == 0;
  }

  /** Creates a new hex of the given type at the given position
   *  Position remains selected and switches the editing mode to edit afterwards.
   *  Does nothing if the current position isn't empty
   **/
  private function createAndAddHex(position : Point, hexType : HexType) {
    trace("Creating hex at " + position + " of type " + hexType);
    while(position.row < 0) {
      boardModel.addRowTop();
      boardView.addRowTop();

      boardView.vertMargin -= BoardView.ROW_HEIGHT;
      position = position.add(Point.DOWN);
    }
    while(position.col < 0) {
      //Add cols in multiples of two
      for(i in 0...2) {
        boardModel.addColLeft();
        boardView.addColLeft();
        boardView.horizMargin -= BoardView.COL_WIDTH;
        position = position.add(Point.RIGHT);
      }
    }

    boardModel.ensureSize(position.row+1, position.col+1);
    boardView.ensureSize(position.row+1, position.col+1);

    if (boardModel.getAt(position) != null) return;

    boardModel.setAt(position, switch(hexType) {
      case HexType.PRISM: new Prism();
      case HexType.SOURCE: new Source();
      case HexType.SINK: new Sink();
      case HexType.ROTATOR: new Rotator();
    });

    boardView.setAt(position, switch(hexType){
      case HexType.PRISM: prepPrismSprite(new PrismSprite());
      case HexType.SOURCE: prepSourceSprite(new SourceSprite());
      case HexType.SINK: prepSinkSprite(new SinkSprite());
      case HexType.ROTATOR: prepRotatorSprite(new RotatorSprite());
    });

    if (editor != null) {
      editor.highlightLocked = false;
      editor.tearDownCreate();
    }

    viewNeedsSync = true;
  }

  /** Sets the presence of the given color for the source at the given location */
  private inline function setColorOnSource(position : Point, color : Color, present : Bool) : Void {
    var sourceModel : Source = boardModel.getAt(position).asSource();
    var sourceSprite : SourceSprite = boardView.getAt(position).asSourceSprite();

    if (present) {
      sourceModel.addColor(color);
      sourceSprite.litColor = sourceModel.getCurrentColor();
      trace("Added " + color + " to Source at " + position);
    } else {
      sourceModel.removeColor(color);
      sourceSprite.litColor = sourceModel.getCurrentColor();
      trace("Removed " + color + " from Source at " + position);
    }

    viewNeedsSync = true;
  }

  /** Deletes the hex at the given position, if any */
  private inline function deleteHex(position : Point) : Void {
    if (position == null){
      return; //mouse is OOB, nothing to do
    } else if (boardModel.getAt(position, true) != null){
      boardModel.removeAt(position);
      boardView.removeAt(position);
      trace("Hex at " + position +" deleted");
      viewNeedsSync = true;
    }
  }

  /**
   * Destroy function called when this state is swapped away.
   * sourceFile left so it can be reloaded
   **/
  public override function destroy() {
    super.destroy();

    for(inputThrottler in inputThrottlers) {
      inputThrottler.destroy();
    }

    resetFields(false);
  }
}
