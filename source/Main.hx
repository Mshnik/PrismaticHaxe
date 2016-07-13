package;

import test.*;
import openfl.display.Sprite;
import flixel.FlxGame;

class Main extends Sprite {

  @final private static var RUN_TESTS = true;

  public function new() {
    super();

    if (RUN_TESTS) {
      runTests();
    } else {
      runGame();
    }
  }

  function runGame() {
    addChild(new FlxGame(0, 0, MenuState));
  }

  static function runTests() {
    trace("");
    trace("Running Tests");
    var r = new haxe.unit.TestRunner();

    r.add(new TestColors());

    r.run();
    trace(r.result);
  }
}
