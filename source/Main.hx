package;

import flash.utils.Timer;
import openfl.Lib;
import test.*;
import openfl.display.Sprite;
import flixel.FlxGame;

class Main extends Sprite {

  @final private static var RUN_TESTS = true;

  public function new() {
    super();

    if (RUN_TESTS) {
      runTests();
      haxe.Timer.delay(quit,1000);
    } else {
      runGame();
    }
  }

  function runGame() {
    addChild(new FlxGame(0, 0, MenuState));
  }

  function runTests() {
    trace("");
    trace("Running Tests");
    var r = new haxe.unit.TestRunner();

    r.add(new TestUtil());
    r.add(new TestColors());
    r.add(new TestHex());
    r.add(new TestBoard());

    r.run();
    trace(r.result);
  }

  function quit() {
    Lib.fscommand("quit");
  }
}
