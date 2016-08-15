package view;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

using view.EditorView.BoardActionUtils;

class EditorView extends FlxTypedGroup<FlxSprite> {

  private static var HEIGHT : Int = 50;

  /** The action selector */
  private var actionSelector : FlxUIDropDownMenu;
  /** The currently selected action by the action selector */
  public var action(default, null) : BoardAction;

  /** True if the highlight should stop moving with the mouse (when a hex is actively being edited) */
  public var highlightLocked(default, default) : Bool;

  private var createButtons : Array<FlxButton>;
  public var createButtonsAdded(default, null) : Bool;

  public function new() {
    super();

    var y : Int = FlxG.height - HEIGHT;

    var bg = new FlxSprite(0, y).makeGraphic(FlxG.width, HEIGHT, FlxColor.BLACK);
    add(bg);

    actionSelector = new FlxUIDropDownMenu(0,y,FlxUIDropDownMenu.makeStrIdLabelArray(["Play","Edit","Create","Delete","Move"]), onActionSelection);
    add(actionSelector);
    action = BoardAction.PLAY;

    highlightLocked = false;
    createButtonsAdded = false;
  }

  /** Programatically selects the current action from the drop down. Returns this */
  public function selectAction(action : BoardAction) : EditorView {
    var str = action.toNiceString();
    if (actionSelector.selectedLabel != str) {
      actionSelector.selectedLabel = str;
      onActionSelection(str);
    }
    return this;
  }

  /** Dismisses the create buttons. Returns this */
  public function dismissCreateButtons() : EditorView {
    for (btn in createButtons) {
      remove(btn);
    }
    createButtonsAdded = false;
    return this;
  }

  /** Sets the handlers for the four create buttons. Returns this */
  public function withCreateHandlers(createPrism : Void -> Void, createSource : Void -> Void,
                                     createSink : Void -> Void, createRotator : Void -> Void) : EditorView {
    if (createButtons != null) {
      for(btn in createButtons) {
        remove(btn);
      }
    }
    createButtons = [new FlxButton(0,0,"Create Prism",createPrism), new FlxButton(0,0,"Create Source",createSource),
                     new FlxButton(0,0,"Create Sink",createSink), new FlxButton(0,0,"Create Rotator",createRotator)];
    return this;
  }

  private function onActionSelection(action : String) {
   this.action = Type.createEnum(BoardAction, action.toUpperCase());
    highlightLocked = false;
    if (this.action != BoardAction.CREATE && createButtonsAdded) {
      dismissCreateButtons();
    }
  }

  public override function update(dt : Float) {
    super.update(dt);

    if (FlxG.mouse.justPressed && action == BoardAction.CREATE && !createButtonsAdded) {
      highlightLocked = true;
      createButtonsAdded = true;

      var dy = createButtons[0].height * 1.5;
      for(btn in createButtons) {
        btn.x = FlxG.mouse.x - btn.width/2;
        btn.y = FlxG.mouse.y - btn.height/2 + dy;
        dy += btn.height;
        add(btn);
      }
    }
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
