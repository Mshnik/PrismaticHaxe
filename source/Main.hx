package;

import openfl.display.Sprite;
import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.FlxGame;

import common.Point;
import controller.PlayState;
import model.Hex;

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
    Point.clearPool();
    Hex.resetIDs();
  }

  function runGame() {
    var g = new FlxGame(0, 0, PlayState);
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
