package;


import openfl.display.Sprite;
import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.FlxGame;

import common.Point;
import model.Hex;
import view.BoardView;
import controller.MainMenuState;
import controller.LevelSelectState;
import controller.InputController;
import controller.SoundController;

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

    //Controllers
    SoundController.init();

    //Input
    InputController.init();

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
