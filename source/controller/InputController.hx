package controller;

import openfl.Assets;
import haxe.xml.Fast;
import flixel.FlxG;

/** Container class for key and mouse bindings across the game. Can be modified mid game. */
class InputController {
  private function new() {
    throw "Illegal Construction";
  }

  private static var KEYS = "keys";
  private static var CODE_ATTR = "code";

  /** Helper for init, returns the 'code' attribute of the given Fast */
  private static function getCodeForKey(keys : Fast, key : String) : Int {
    return Std.parseInt(keys.nodes.resolve(key).first().att.resolve(CODE_ATTR));
  }

  public static function init() {
    var content = new Fast(Xml.parse(Assets.getText(AssetPaths.input_settings__xml)).firstElement());

    var keys : Fast = content.nodes.resolve(KEYS).first();
    BACK = getCodeForKey(keys, "BACK");
    LEFT = getCodeForKey(keys, "LEFT");
    RIGHT = getCodeForKey(keys, "RIGHT");
    UP = getCodeForKey(keys, "UP");
    DOWN = getCodeForKey(keys, "DOWN");

    MODE_PLAY = getCodeForKey(keys, "MODE_PLAY");
    MODE_CREATE = getCodeForKey(keys, "MODE_CREATE");
    MODE_EDIT = getCodeForKey(keys, "MODE_EDIT");
    MODE_MOVE = getCodeForKey(keys, "MODE_MOVE");
    MODE_DELETE = getCodeForKey(keys, "MODE_DELETE");
  }

  //General purpose keys
  public static var BACK : Int;
  public static var LEFT : Int;
  public static var RIGHT : Int;
  public static var UP : Int;
  public static var DOWN : Int;

  //Keys only used in Editing
  public static var MODE_PLAY : Int;
  public static var MODE_CREATE : Int;
  public static var MODE_EDIT : Int;
  public static var MODE_MOVE : Int;
  public static var MODE_DELETE : Int;

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

  public static inline function CHECK_MODE_PLAY() : Bool {
    return check(MODE_PLAY);
  }
  public static inline function CHECK_MODE_CREATE() : Bool {
    return check(MODE_CREATE);
  }
  public static inline function CHECK_MODE_EDIT() : Bool {
    return check(MODE_EDIT);
  }
  public static inline function CHECK_MODE_MOVE() : Bool {
    return check(MODE_MOVE);
  }
  public static inline function CHECK_MODE_DELETE() : Bool {
    return check(MODE_DELETE);
  }
}
