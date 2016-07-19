package;

import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import common.Point;
import flash.utils.Timer;
import openfl.Lib;
import test.*;
import openfl.display.Sprite;
import flixel.FlxGame;

class Main extends Sprite {

  public function new() {
    super();

    #if TEST_MODE
    runTests();
    haxe.Timer.delay(quit, 1000);
    #else
    prepForGame();
    runGame();
    #end
  }

  function prepForGame() {
    Point.clearPool();
  }

  function runGame() {
    var g = new FlxGame(0, 0, PlayState);
    FlxG.plugins.add(new FlxMouseControl());
    addChild(g);
  }

  function runTests() {
    trace("");
    trace("Running Tests");
    var r = new haxe.unit.TestRunner();

    r.add(new TestUtil());
    r.add(new TestPoint());
    r.add(new TestArray2D());
    r.add(new TestColors());
    r.add(new TestHex());
    r.add(new TestPrism());
    r.add(new TestSource());
    r.add(new TestSink());

    r.run();
    trace(r.result);
  }

  function quit() {
    Lib.fscommand("quit");
  }
}
