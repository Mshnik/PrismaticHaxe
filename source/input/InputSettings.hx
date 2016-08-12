package input;

/** Container class for key and mouse bindings across the game. Can be modified mid game. */
import openfl.Assets;
import haxe.xml.Fast;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using input.InputSettings;

class InputSettings {
  private function new() {
    throw "Illegal Construction";
  }

  private static var KEYS = "keys";
  private static var CODE_ATTR = "code";

  /** Helper for init, returns the 'code' attribute of the given Fast */
  private static function getCodeAttr(elm : Fast) : Int {
    return Std.parseInt(elm.att.resolve(CODE_ATTR));
  }

  public static function init() {
    var content = new Fast(Xml.parse(Assets.getText(AssetPaths.input_settings__xml)).firstElement());

    var keys : Fast = content.nodes.resolve(KEYS).first();
    BACK = keys.nodes.resolve("BACK").first().getCodeAttr();
    LEFT = keys.nodes.resolve("LEFT").first().getCodeAttr();
    RIGHT = keys.nodes.resolve("RIGHT").first().getCodeAttr();
    UP = keys.nodes.resolve("UP").first().getCodeAttr();
    DOWN = keys.nodes.resolve("DOWN").first().getCodeAttr();
  }

  public static var BACK : Int;
  public static var LEFT : Int;
  public static var RIGHT : Int;
  public static var UP : Int;
  public static var DOWN : Int;

  private static inline function check(k : Int) : Bool {
    return FlxG.keys.anyJustPressed([k]);
  }

  public static inline function CHECK_BACK() : Bool {
    return check(BACK);
  }
  public static inline function CHECK_LEFT() : Bool {
    return check(LEFT);
  }
  public static inline function CHECK_RIGHT() : Bool {
    return check(RIGHT);
  }
  public static inline function CHECK_DOWN() : Bool {
    return check(DOWN);
  }
  public static inline function CHECK_UP() : Bool {
    return check(UP);
  }

}
