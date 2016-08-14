package view;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class EditorView extends FlxTypedGroup<FlxSprite> {

  private static var HEIGHT : Int = 50;

  /** The currently selected action by the action selector */
  private var action : BoardAction;

  public function new() {
    super();

    var y : Int = FlxG.height - HEIGHT;

    var bg = new FlxSprite(0, y).makeGraphic(FlxG.width, HEIGHT, FlxColor.BLACK);
    add(bg);

    var actionSelector = new FlxUIDropDownMenu(0,y,FlxUIDropDownMenu.makeStrIdLabelArray(["Edit","Create","Delete","Move"]), onActionSelection);
    add(actionSelector);
    action = BoardAction.EDIT;
  }

  private function onActionSelection(action : String) {
   this.action = Type.createEnum(BoardAction, action.toUpperCase());
  }
}

enum BoardAction {
  EDIT;
  CREATE;
  DELETE;
  MOVE;
}
