package controller;

import view.HUDView;
import view.PrismSprite;
import view.FlxUICheckBoxWithFullCallback;
import common.Color;
import common.ColorUtil;
import common.HexType;
import controller.util.BoardAction;

import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

using controller.util.BoardAction.BoardActionUtils;
using common.CollectionExtender;

class EditorController extends FlxTypedGroup<FlxSprite> {

  private static inline var MARGIN : Int = 10;

  private static inline var BACKGROUND_COLOR : FlxColor =  0x99000000;
  /** The background image. Also used to check for mouse presence */
  private var background : FlxSprite;
  /** Background size when there are no other items in menu */
  private var backgroundBaseSize :FlxPoint;

  /** Button that prompts for loading a board */
  private var loadBoardButton : FlxButton;
  /** The Filepicker that handles file selection. */
  private var filePicker : FilePicker;
  /** The function to call when the filePicker chooses a file. */
  private var onFilePicked : String -> Void;

  /** The action selector */
  private var actionSelector : FlxUIDropDownMenu;
  /** The currently selected action by the action selector */
  public var action(default, set) : BoardAction;
  /** The action selector's position when there aren't any other items in menu */
  private var actionSelectorBasePosition : FlxPoint;

  /** True if the highlight should stop moving with the mouse (when a hex is actively being edited) */
  public var highlightLocked(default, default) : Bool;
  /** Function that returns whether the mouse is currently in a valid position on the board */
  private var isMouseValid : Void -> Bool;
  /** Function that returns the current x/y of the selected location on the board. Results should be put() after use. */
  private var getHighlightPosition : Void -> FlxPoint;

  /** Buttons added to create a new hex. */
  private var createButtons : Array<FlxButton>;
  /** Action handlers for the create buttons */
  private var createHandlers : Array<Void -> Void>;
  /** Function to call to check whether to display the rotator button */
  private var shouldShowRotatorButton : Void -> Bool;
  /** True if the create buttons are currently added and positioned on the screen */
  public var createButtonsAdded(default, null) : Bool;
  /** True if one extra frame should be taken between adding the create buttons again */
  private var createButtonsWaitFrame : Bool;

  /** Function to call to check if the current tile can be edited */
  private var canEdit : Void -> Bool;
  /** Function to call to get the type of Hex being edited */
  private var getEditedHexType : Void -> HexType;
  /** The current hex edit type. Kept after creation so teardown can work correctly */
  private var editedHexType : HexType;

  /** Function that resets the checkboxes when starting to edit a source */
  private var resetSourceCheckBoxes : Void -> Array<Color>;
  /** Check boxes for colors when editing sources */
  private var editSourceCheckBoxes : Map<Color,FlxUICheckBoxWithFullCallback>;

  /** Selector for color for putting connectors on a prism. */
  private var editPrismColorSelector : FlxUIDropDownMenu;
  /** The current color for editing prisms */
  public var editPrismColor(default, set) : Color;
  /** Selector for from side for connectors on a prism. */
  private var editPrismFromSideSelector : FlxUIDropDownMenu;
  /** The current from side for editing prisms */
  private var editPrismFromSide(default, null) : Int;
  /** Selector for to side for connectors on a prism. */
  private var editPrismToSideSelector : FlxUIDropDownMenu;
  /** The current to side for editing prisms */
  private var editPrismToSide(default, null) : Int;
  /** Button that applies the current prism editing settings to the selected prism */
  private var editPrismButton : FlxButton;
  /** Function to call to edit the current prism */
  private var editPrismFunc : Int -> Int -> Color -> Void;
  /** Array of selector references, to cycle between */
  private var editPrismSelectorsArr : Array<FlxUIDropDownMenu>;
  /** Current index in selectors for quick select */
  private var editPrismQuickSelectIndex : Int;
  /** True if the demo connector is added, false otherwise */
  private var editPrismDemoAdded : Bool;
  /** Demo of connector that would be added by hitting apply now. Updates with selector updates */
  private var editPrismDemoConnector : FlxSprite;

  /** Function to call when the current action is delete */
  private var deleteHandler : Void -> Void;

  public function new() {
    super();

    //Init base contents of editor
    actionSelector = new FlxUIDropDownMenu(0,0,FlxUIDropDownMenu.makeStrIdLabelArray(["Play","Edit","Create","Delete","Move"]), onActionSelection);
    actionSelector.x = MARGIN;
    actionSelector.y = FlxG.height - (actionSelector.header.height + MARGIN);
    actionSelectorBasePosition = FlxPoint.get(actionSelector.x, actionSelector.y);
    actionSelector.dropDirection = FlxUIDropDownMenuDropDirection.Up;
    action = BoardAction.PLAY;
    background = new FlxSprite(0, 0)
                  .makeGraphic(Std.int(actionSelector.width + MARGIN * 2), Std.int(actionSelector.header.height + MARGIN*2), BACKGROUND_COLOR);
    background.y = FlxG.height - background.height;
    backgroundBaseSize = FlxPoint.get(background.width, background.height);
    loadBoardButton = new FlxButton(HUDView.TOP_MARGIN, HUDView.TOP_MARGIN, "Load Board", selectBoardToLoad);

    //Init Hex Creation
    highlightLocked = false;
    createButtonsAdded = false;
    createButtonsWaitFrame = false;
    isMouseValid = null;
    canEdit = null;

    //Init Editing
    getEditedHexType = null;
    editedHexType = null;

    //Init Source Editing
    resetSourceCheckBoxes = null;
    editSourceCheckBoxes = new Map<Color, FlxUICheckBoxWithFullCallback>();
    for (c in ColorUtil.realColors()) {
      var checkBox = new FlxUICheckBoxWithFullCallback(0,0,null,null,ColorUtil.toString(c));
      checkBox.text = ColorUtil.toString(c);

      checkBox.color = ColorUtil.toFlxColor(c, true);
      checkBox.button.up_color = checkBox.color;
      checkBox.button.down_color = checkBox.color;
      checkBox.button.over_color = checkBox.color;
      checkBox.button.up_toggle_color = checkBox.color;
      checkBox.button.down_toggle_color = checkBox.color;
      checkBox.button.over_toggle_color = checkBox.color;

      checkBox.x = MARGIN;
      editSourceCheckBoxes[c] = checkBox;
    }

    //Init Prism Editing
    var sidesArr : Array<String> = ["0","1","2","3","4","5"];
    editPrismToSideSelector = new FlxUIDropDownMenu(MARGIN,0,FlxUIDropDownMenu.makeStrIdLabelArray(sidesArr), onPrismToSideSelection);
    editPrismFromSideSelector = new FlxUIDropDownMenu(MARGIN,0,FlxUIDropDownMenu.makeStrIdLabelArray(sidesArr), onPrismFromSideSelection);
    editPrismColorSelector = new FlxUIDropDownMenu(MARGIN,0,FlxUIDropDownMenu.makeStrIdLabelArray(Type.allEnums(Color).map(ColorUtil.toString)), onPrismColorSelection);
    editPrismButton = new FlxButton(MARGIN,0,"Apply",editPrism);

    editPrismButton.y = FlxG.height - (editPrismButton.height + MARGIN);
    editPrismToSideSelector.y = editPrismButton.y - (editPrismColorSelector.header.height + MARGIN);
    editPrismFromSideSelector.y = editPrismToSideSelector.y - (editPrismColorSelector.header.height + MARGIN);
    editPrismColorSelector.y = editPrismFromSideSelector.y - (editPrismColorSelector.header.height + MARGIN);

    editPrismToSideSelector.dropDirection = FlxUIDropDownMenuDropDirection.Up;
    editPrismFromSideSelector.dropDirection = FlxUIDropDownMenuDropDirection.Up;
    editPrismColorSelector.dropDirection = FlxUIDropDownMenuDropDirection.Up;

    editPrismQuickSelectIndex = 0;
    editPrismSelectorsArr = [editPrismColorSelector, editPrismFromSideSelector, editPrismToSideSelector];

    editPrismDemoAdded = false;
    editPrismFromSide = 0;
    editPrismToSide = 0;
    editPrismColor = Color.ANY;
    updatePrismDemoConnector(); //Fetches basic demo connector, so it's not null.

    //Init Other Functions
    deleteHandler = null;

    //Add base contents
    add(background);
    add(actionSelector);
    add(loadBoardButton);
  }

  /** Returns the width of the load button. Used to shift the HUD */
  public inline function getLoadButtonOffset() : Float {
    return loadBoardButton.x + loadBoardButton.width;
  }

  /** Allows the user to select a board to load */
  private inline function selectBoardToLoad() : Void {
    if (filePicker != null) filePicker.pickFile();
  }

  /** Event listener called when a new action is selected via mouse. Just passes control off to set_action */
  private inline function onActionSelection(action : String) {
    this.action = Type.createEnum(BoardAction, action.toUpperCase());
  }

  /** Programatically selects the current action from the drop down. Returns this */
  public inline function set_action(action : BoardAction) : BoardAction {
      highlightLocked = false;
      actionSelector.selectedLabel = action.toNiceString();
        tearDownCreate();
        tearDownEdit();
    return this.action = action;
  }

  /** Sets the handler for file picking. Returns this */
  public inline function withFilePickingHandler(onFilePicked : String -> Void) : EditorController {
    this.onFilePicked = onFilePicked;
    filePicker = new FilePicker(this.onFilePicked);
    return this;
  }

  /** Sets the handlers for the four create buttons. Returns this */
  public inline function withCreateHandlers(createPrism : Void -> Void, createSource : Void -> Void,
                                     createSink : Void -> Void, createRotator : Void -> Void,
                                     shouldShowRotatorButton : Void -> Bool) : EditorController {
    if (createButtons != null) {
      for(btn in createButtons) {
        remove(btn);
      }
    }
    createHandlers = [function(){createButtonsWaitFrame = true; createPrism();},
                      function(){createButtonsWaitFrame = true; createSource();},
                      function(){createButtonsWaitFrame = true; createSink();},
                      function(){createButtonsWaitFrame = true; createRotator();}];
    createButtons = [new FlxButton(0,0,"Create Prism",createHandlers[0]), new FlxButton(0,0,"Create Source",createHandlers[1]),
                     new FlxButton(0,0,"Create Sink",createHandlers[2]), new FlxButton(0,0,"Create Rotator",createHandlers[3])];
    this.shouldShowRotatorButton = shouldShowRotatorButton;
    return this;
  }

  /** Sets the mouseValid handler. Returns this. */
  public inline function withMouseValidHandlers(isMouseValid : Void -> Bool, getHighlightPosition : Void -> FlxPoint) : EditorController {
    this.isMouseValid = isMouseValid;
    this.getHighlightPosition = getHighlightPosition;
    return this;
  }

  /** Sets the edit handlers. Returns this. */
  public inline function withEditHandlers(validator : Void -> Bool, getEditingType : Void -> HexType) : EditorController {
    this.canEdit = validator;
    this.getEditedHexType = getEditingType;
    return this;
  }

  /** Sets the handlers for source editing. Returns this. */
  public inline function withSourceEditingHandlers(resetFunc : Void -> Array<Color>, checkboxFunc : String -> Bool -> Void) : EditorController {
    this.resetSourceCheckBoxes = resetFunc;
    for(chkbx in editSourceCheckBoxes.iterator()) {
      chkbx.fullCallback = checkboxFunc;
    }
    return this;
  }

  /** Sets the handlers for prism editing. Returns this. */
  public inline function withPrismEditingHandler(editFunc : Int -> Int -> Color -> Void) : EditorController {
    editPrismFunc = editFunc;
    return this;
  }

  /** Sets the delete handler. Returns this. */
  public inline function withDeleteHandler(func : Void -> Void) : EditorController {
    this.deleteHandler = func;
    return this;
  }

  public override function update(dt : Float) {
    super.update(dt);

    //Check Back (Esc) for menu dismissal
    if (InputController.CHECK_BACK()) {
      goBack();
    }

    //Check for action quickselect
    if (InputController.CHECK_MODE_PLAY()) {
      action = BoardAction.PLAY;
    } else if (InputController.CHECK_MODE_CREATE()) {
      action = BoardAction.CREATE;
    } else if (InputController.CHECK_MODE_EDIT()) {
      action = BoardAction.EDIT;
    } else if (InputController.CHECK_MODE_MOVE()) {
      action = BoardAction.MOVE;
    } else if (InputController.CHECK_MODE_DELETE()) {
      action = BoardAction.DELETE;
    }

    //Check quickselect for create menu
    if (action == BoardAction.CREATE && highlightLocked) {
      if (InputController.CHECK_ONE()) createHandlers[0]();
      if (InputController.CHECK_TWO()) createHandlers[1]();
      if (InputController.CHECK_THREE()) createHandlers[2]();
      if (InputController.CHECK_FOUR() && shouldShowRotatorButton()) createHandlers[3]();
    }

    //Check quickselect for edit menu for sources
    if (action == BoardAction.EDIT && editedHexType == HexType.SOURCE) {
      if (InputController.CHECK_ONE()) editSourceCheckBoxes[Color.GREEN].toggle();
      if (InputController.CHECK_TWO()) editSourceCheckBoxes[Color.BLUE].toggle();
      if (InputController.CHECK_THREE()) editSourceCheckBoxes[Color.YELLOW].toggle();
      if (InputController.CHECK_FOUR()) editSourceCheckBoxes[Color.RED].toggle();
    }

    //Check quickselect for edit menu for prisms
    if (action == BoardAction.EDIT && editedHexType == HexType.PRISM) {
      if (InputController.CHECK_NEXT()){
        editPrismSelectorsArr[editPrismQuickSelectIndex].header.background.color = FlxColor.WHITE;
        editPrismQuickSelectIndex = (editPrismQuickSelectIndex+1)%editPrismSelectorsArr.length;
        editPrismSelectorsArr[editPrismQuickSelectIndex].header.background.color = FlxColor.YELLOW;
      }
      if (InputController.CHECK_ENTER()) editPrism();
      var arr = InputController.CHECK_NUMBERS;
      for (i in 0...arr.length) {
        if (arr[i]()){
          var str = editPrismSelectorsArr[editPrismQuickSelectIndex].getBtnByIndex(i).getLabel().text;
          editPrismSelectorsArr[editPrismQuickSelectIndex].selectedLabel = str;
          editPrismSelectorsArr[editPrismQuickSelectIndex].callback(str);
        }
      }
    }

    //Check state changes to update menu
    if (action == BoardAction.CREATE && FlxG.mouse.justReleased && !createButtonsWaitFrame && !createButtonsAdded && isMouseValid()) {
      highlightLocked = true;
      setUpCreate();
    }
    if (FlxG.mouse.justReleased && (action == BoardAction.EDIT || action == BoardAction.CREATE && !createButtonsWaitFrame) && canEdit()){
      action = BoardAction.EDIT;
      highlightLocked = true;
      setUpEdit();
    }
    if (action == BoardAction.DELETE && FlxG.mouse.pressed && deleteHandler != null && isMouseValid()) {
      deleteHandler();
    }

    createButtonsWaitFrame = false;
  }

  /** Resets the background image and action selector to their base sizes and positions.
   * Should be called when transitioning out of a mode with a fuller menu
   **/
  private inline function resetBackgroundAndSelectorToBase() {
    actionSelector.x = actionSelectorBasePosition.x;
    actionSelector.y = actionSelectorBasePosition.y;
    background.width = backgroundBaseSize.x;
    background.height = backgroundBaseSize.y;
    background.y = FlxG.height - background.height;
  }

  /** Sets up buttons for create */
  private inline function setUpCreate() : EditorController {
    var dy = createButtons[0].height * 1.5;
    for(btn in createButtons) {
      btn.x = FlxG.mouse.x - btn.width/2;
      btn.y = FlxG.mouse.y - btn.height/2 + dy;
      dy += btn.height;
      if (btn.text != "Create Rotator" || shouldShowRotatorButton()) {
        add(btn);
      }
    }
    createButtonsAdded = true;
    return this;
  }

  /** Dismisses the create buttons. Returns this */
  public inline function tearDownCreate() : EditorController {
    if (createButtonsAdded) {
      for (btn in createButtons) {
        remove(btn);
      }
      createButtonsAdded = false;
      createButtonsWaitFrame = true;
    }
    return this;
  }

  /** Sets up the menu for edit. First tears down if the new edited hex type is different than the old */
  private inline function setUpEdit() : EditorController {
    var newHexType : HexType = getEditedHexType();
    if (newHexType != editedHexType) {
      tearDownEdit();
      editedHexType = newHexType;
      if (newHexType == HexType.PRISM) {
        add(editPrismColorSelector);
        add(editPrismFromSideSelector);
        add(editPrismToSideSelector);
        add(editPrismButton);

        editPrismDemoAdded = true;
        updatePrismDemoConnector();
        var pt = getHighlightPosition();
        editPrismDemoConnector.x = pt.x - editPrismDemoConnector.width/2;
        editPrismDemoConnector.y = pt.y - editPrismDemoConnector.height/2;
        pt.put();

        actionSelector.y = editPrismColorSelector.y - (editPrismColorSelector.header.height + MARGIN);
        background.height += (editPrismColorSelector.header.height + editPrismFromSideSelector.header.height
                              +  editPrismToSideSelector.header.height + editPrismButton.height + 4*MARGIN);
        editPrismSelectorsArr[editPrismQuickSelectIndex].header.background.color = FlxColor.YELLOW;
      } else if (newHexType == HexType.SOURCE) {
        var arr : Array<Color> = resetSourceCheckBoxes();
        for(color in editSourceCheckBoxes.keys()) {
          add(editSourceCheckBoxes[color]);
          editSourceCheckBoxes[color].checked = arr.contains(color);
          editSourceCheckBoxes[color].y = actionSelector.y;
          actionSelector.y -= (editSourceCheckBoxes[color].height + MARGIN);
          background.height += (editSourceCheckBoxes[color].height + MARGIN);
        }
      }
      background.makeGraphic(Std.int(background.width), Std.int(background.height), BACKGROUND_COLOR);
      background.y = FlxG.height - background.height;
    }
    return this;
  }

  /** Tears down the menu for edit. Does nothing if already removed. */
  private inline function tearDownEdit() : EditorController {
    if (editedHexType != null) {
      if (editedHexType == HexType.PRISM) {
        remove(editPrismColorSelector);
        remove(editPrismFromSideSelector);
        remove(editPrismToSideSelector);
        remove(editPrismButton);
        remove(editPrismDemoConnector);
        editPrismDemoAdded = false;
        editPrismSelectorsArr[editPrismQuickSelectIndex].header.background.color = FlxColor.WHITE;
        editPrismQuickSelectIndex = 0;
      } else if (editedHexType == HexType.SOURCE) {
        for(chkbx in editSourceCheckBoxes) {
          remove(chkbx);
        }
      }
      editedHexType = null;

      resetBackgroundAndSelectorToBase();
    }
    return this;
  }

  /** Event called when the prism color selector changes selection. */
  private inline function onPrismColorSelection(c : String) {
    editPrismColor = Type.createEnum(Color, c);
  }

  /** Sets the current prism editing color */
  private inline function set_editPrismColor(c : Color) : Color {
    var c = this.editPrismColor = c;
    updatePrismDemoConnector();
    return c;
  }

  /** Event called when the prism from side selector changes selection. */
  private inline function onPrismFromSideSelection(s : String) {
    editPrismFromSide = Std.parseInt(s);
    updatePrismDemoConnector();
  }

  /** Event called when the prism to side selector changes selection. */
  private inline function onPrismToSideSelection(s : String) {
    editPrismToSide = Std.parseInt(s);
    updatePrismDemoConnector();
  }

  /** Helper for editing the currently selected prism, as a buttonable callback */
  private inline function editPrism() {
    if (editPrismFunc != null) {
      editPrismFunc(editPrismFromSide, editPrismToSide, editPrismColor);
    }
  }

  /** Updates the prism demo connector for the current selector settings. Returns the new sprite to use. */
  private inline function updatePrismDemoConnector() : FlxSprite {
    var x = 0.0;
    var y = 0.0;
    if (editPrismDemoAdded) {
      remove(editPrismDemoConnector);
      x = editPrismDemoConnector.x;
      y = editPrismDemoConnector.y;
    }
    editPrismDemoConnector = PrismSprite.getConnectorSprite(editPrismFromSide, editPrismToSide);
    editPrismDemoConnector.color = ColorUtil.toFlxColor(editPrismColor, true);
    if (editPrismDemoAdded) {
      editPrismDemoConnector.x = x;
      editPrismDemoConnector.y = y;
      add(editPrismDemoConnector);
    }
    return editPrismDemoConnector;
  }

  /** Moves one step back in editing */
  public function goBack() {
    if (action == BoardAction.CREATE) {
      if (createButtonsAdded) {
        tearDownCreate();
        highlightLocked = false;
        return;
      }
    } else if (action == BoardAction.EDIT) {
      if (highlightLocked) {
        tearDownEdit();
        highlightLocked = false;
        return;
      }
    }
    //If we made it here, just return to play mode
    action = BoardAction.PLAY;
  }

  /** Returns true if the mouse is currently hovering over a part of this */
  public inline function mousePresent() : Bool {
    var pt = FlxG.mouse.getPosition();
    var x = background.overlapsPoint(pt) || actionSelector.overlapsPoint(pt);
    pt.put();
    return x;
  }

  public override function destroy() {
    //Remove all optional stuff and destroy it here to make sure nothing is missed
    for(btn in createButtons) {
      remove(btn);
      btn.destroy();
    }
    createButtons = null;
    createButtonsAdded = false;

    for(chkbx in editSourceCheckBoxes.iterator()) {
      remove(chkbx);
      chkbx.destroy();
    }
    editSourceCheckBoxes = null;

    remove(editPrismColorSelector);
    editPrismColorSelector.destroy();
    editPrismColorSelector = null;
    remove(editPrismToSideSelector);
    editPrismToSideSelector.destroy();
    editPrismToSideSelector = null;
    remove(editPrismFromSideSelector);
    editPrismFromSideSelector.destroy();
    editPrismFromSideSelector = null;
    remove(editPrismButton);
    editPrismButton.destroy();
    editPrismButton = null;
    editPrismSelectorsArr = null;
    remove(editPrismDemoConnector);
    //dont destroy editPrismDemoConnector - reference gotten from elsewhere.
    editPrismDemoConnector = null;

    super.destroy();

    background = null;
    actionSelector = null;
    loadBoardButton = null;
    filePicker = null;

    //Put and nullify points
    backgroundBaseSize.put();
    backgroundBaseSize = null;
    actionSelectorBasePosition.put();
    actionSelectorBasePosition = null;

    //Nullify functional references
    onFilePicked = null;
    createHandlers = null;
    isMouseValid = null;
    getHighlightPosition = null;
    shouldShowRotatorButton = null;
    canEdit = null;
    getEditedHexType = null;
    resetSourceCheckBoxes = null;
    editPrismFunc = null;
    deleteHandler = null;
  }
}
