package;

import view.PrismSprite;
import model.Hex;
import flash.utils.Timer;
import openfl.display.Sprite;

#if flash
import openfl.Lib;
#end

import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.FlxGame;

import common.Point;
import controller.PlayState;
import test.*;

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
    Hex.resetIDs();
    PrismSprite.initGeometry();
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
    r.add(new TestIntExtender());
    r.add(new TestArrayExtention());
    r.add(new TestPoint());
    r.add(new TestArray2D());
    r.add(new TestColors());
    r.add(new TestHex());
    r.add(new TestPrism());
    r.add(new TestSource());
    r.add(new TestSink());
    r.add(new TestRotator());
    r.add(new TestBoard());
    r.add(new TestXMLParser());

    r.run();
    trace(r.result);
  }

  function quit() {
    #if flash
      Lib.fscommand("quit");
    #else
    #end
  }
}
