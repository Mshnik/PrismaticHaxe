package;

import openfl.display.Sprite;
import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.FlxGame;

import common.Point;
import controller.MainMenuState;
import controller.LevelSelectState;
import model.Hex;
import view.PrismSprite;
import view.BoardView;

#if flash
import openfl.Lib;
#end

class Main extends Sprite {

  public function new() {
    super();

    prepForGame();
    runGame();
  }

  function prepForGame() {
    //Models
    Point.clearPool();
    Hex.resetIDs();

    //Views
    BoardView.initRowAndColDimens();

    //Final Asset Loading/Locating
    LevelSelectState.initLevelPaths();
  }

  function runGame() {
    var g = new FlxGame(0, 0, MainMenuState);
    FlxG.plugins.add(new FlxMouseControl());
    addChild(g);
  }

  function quit() {
    #if flash
      Lib.fscommand("quit");
    #else
      Sys.exit(0);
    #end
  }
}
