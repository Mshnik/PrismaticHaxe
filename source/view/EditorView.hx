package view;

import controller.InputController;
import common.Color;
import common.ColorUtil;
import common.HexType;
import view.EditorView.BoardAction;

import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

using view.EditorView.BoardActionUtils;
using common.CollectionExtender;

class EditorView extends FlxTypedGroup<FlxSprite> {

  private static inline var MARGIN : Int = 10;

  private static inline var BACKGROUND_COLOR : FlxColor =  0x99000000;
  /** The background image. Also used to check for mouse presence */
  private var background : FlxSprite;
  /** Background size when there are no other items in menu */
  private var backgroundBaseSize :FlxPoint;

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

  /** Buttons added to create a new hex. */
  private var createButtons : Array<FlxButton>;
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
  /** Function to call when the current action is delete */
  private var deleteHandler : Void -> Void;

  public function new() {
    super();

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

    highlightLocked = false;
    createButtonsAdded = false;
    createButtonsWaitFrame = false;
    isMouseValid = null;

    canEdit = null;
    getEditedHexType = null;
    editedHexType = null;
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

    deleteHandler = null;

    add(background);
    add(actionSelector);
  }

  /** Event listener called when a new action is selected via mouse. Just passes control off to set_action */
  private inline function onActionSelection(action : String) {
    this.action = Type.createEnum(BoardAction, action.toUpperCase());
  }

  /** Programatically selects the current action from the drop down. Returns this */
  public inline function set_action(action : BoardAction) : BoardAction {
    if (this.action != action) {
      actionSelector.selectedLabel = action.toNiceString();
      highlightLocked = false;
      if (action != BoardAction.CREATE) {
        tearDownCreate();
      }
      if (action != BoardAction.EDIT) {
        tearDownEdit();
      }
    }
    return this.action = action;
  }

  /** Sets the handlers for the four create buttons. Returns this */
  public inline function withCreateHandlers(createPrism : Void -> Void, createSource : Void -> Void,
                                     createSink : Void -> Void, createRotator : Void -> Void,
                                     shouldShowRotatorButton : Void -> Bool) : EditorView {
    if (createButtons != null) {
      for(btn in createButtons) {
        remove(btn);
      }
    }
    createButtons = [new FlxButton(0,0,"Create Prism",createPrism), new FlxButton(0,0,"Create Source",createSource),
                     new FlxButton(0,0,"Create Sink",createSink), new FlxButton(0,0,"Create Rotator",createRotator)];
    this.shouldShowRotatorButton = shouldShowRotatorButton;
    return this;
  }

  /** Sets the mouseValid handler. Returns this. */
  public inline function withMouseValidHandler(isMouseValid : Void -> Bool) : EditorView {
    this.isMouseValid = isMouseValid;
    return this;
  }

  /** Sets the edit handlers. Returns this. */
  public inline function withEditHandlers(validator : Void -> Bool, getEditingType : Void -> HexType) : EditorView {
    this.canEdit = validator;
    this.getEditedHexType = getEditingType;
    return this;
  }

  /** Sets the handlers for source editing. Returns this. */
  public inline function withSourceEditingHandler(resetFunc : Void -> Array<Color>, checkboxFunc : String -> Bool -> Void) : EditorView {
    this.resetSourceCheckBoxes = resetFunc;
    for(chkbx in editSourceCheckBoxes.iterator()) {
      chkbx.fullCallback = checkboxFunc;
    }
    return this;
  }

  /** Sets the delete handler. Returns this. */
  public inline function withDeleteHandler(func : Void -> Void) : EditorView {
    this.deleteHandler = func;
    return this;
  }

  public override function update(dt : Float) {
    super.update(dt);

    if (action == BoardAction.CREATE && FlxG.mouse.justReleased && !createButtonsWaitFrame && !createButtonsAdded && isMouseValid()) {
      highlightLocked = true;
      setUpCreate();
    } else if (action == BoardAction.EDIT && FlxG.mouse.justReleased && canEdit()){
      highlightLocked = true;
      setUpEdit();
    } else if (action == BoardAction.DELETE && FlxG.mouse.pressed && deleteHandler != null && isMouseValid()) {
      deleteHandler();
    }

    if (action == BoardAction.EDIT && highlightLocked) {
      if (InputController.CHECK_ONE()) editSourceCheckBoxes[Color.GREEN].toggle();
      if (InputController.CHECK_TWO()) editSourceCheckBoxes[Color.BLUE].toggle();
      if (InputController.CHECK_THREE()) editSourceCheckBoxes[Color.YELLOW].toggle();
      if (InputController.CHECK_FOUR()) editSourceCheckBoxes[Color.RED].toggle();
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
  private inline function setUpCreate() : EditorView {
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
  public inline function tearDownCreate() : EditorView {
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
  private inline function setUpEdit() : EditorView {
    var newHexType : HexType = getEditedHexType();
    if (newHexType != editedHexType) {
      remove(actionSelector,true);
      tearDownEdit();
      editedHexType = newHexType;
      if (newHexType == HexType.PRISM) {

      } else if (newHexType == HexType.SOURCE) {
        var arr : Array<Color> = resetSourceCheckBoxes();
        for(color in editSourceCheckBoxes.keys()) {
          add(editSourceCheckBoxes[color]);
          editSourceCheckBoxes[color].checked = arr.contains(color);
          editSourceCheckBoxes[color].y = actionSelector.y;
          actionSelector.y -= editSourceCheckBoxes[color].height + MARGIN;
          background.height += editSourceCheckBoxes[color].height + MARGIN;
        }
      }
      background.makeGraphic(Std.int(background.width), Std.int(background.height), BACKGROUND_COLOR);
      background.y = FlxG.height - background.height;
      add(actionSelector);
    }
    return this;
  }

  /** Tears down the menu for edit. Does nothing if already removed. */
  private inline function tearDownEdit() : EditorView {
    if (editedHexType != null) {
      if (editedHexType == HexType.PRISM) {

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
}

enum BoardAction {
  PLAY;
  EDIT;
  CREATE;
  DELETE;
  MOVE;
}

class BoardActionUtils {

  public static inline function toNiceString(action : BoardAction) : String {
    var str = Std.string(action);
    return str.charAt(0) + str.substring(1, str.length).toLowerCase();
  }

}
