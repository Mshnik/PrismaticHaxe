package input;

/** Container class for key and mouse bindings across the game. Can be modified mid game. */
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class InputSettings {

  private function new() {
    throw "Illegal Construction";
  }

  private static var BACK_KEY : Int = FlxKey.ESCAPE;

  public static inline function CHECK_BACK_KEY() : Bool {
    return FlxG.keys.anyJustPressed([BACK_KEY]);
  }

}
