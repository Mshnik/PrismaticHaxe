package controller;

import controller.InputController;
import openfl.Assets;
import haxe.xml.Fast;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

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

    for (str in Type.getClassFields(InputController)) {
      var field : Dynamic = Reflect.field(InputController, str);
      if (! Reflect.isFunction(field) && 0 == field) {
        Reflect.setField(InputController, str, getCodeForKey(keys, str));
      }
    }
  }

  //General purpose keys
  public static var BACK : Int;
  public static var ENTER : Int;

  public static var LEFT : Int;
  public static var RIGHT : Int;
  public static var UP : Int;
  public static var DOWN : Int;

  public static var ONE : Int;
  public static var TWO : Int;
  public static var THREE : Int;
  public static var FOUR : Int;
  public static var FIVE : Int;
  public static var SIX : Int;

  //Keys only used in Editing
  public static var MODE_PLAY : Int;
  public static var MODE_CREATE : Int;
  public static var MODE_EDIT : Int;
  public static var MODE_MOVE : Int;
  public static var MODE_DELETE : Int;
  public static var NEXT : Int;

  private static inline function check(k : Int) : Bool {
    return FlxG.keys.anyJustPressed([k]);
  }

  public static inline function CHECK_BACK() : Bool {
    return check(BACK);
  }
  public static inline function CHECK_ENTER() : Bool {
    return check(ENTER);
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

  public static inline function CHECK_ONE() : Bool {
    return check(ONE);
  }
  public static inline function CHECK_TWO() : Bool {
    return check(TWO);
  }
  public static inline function CHECK_THREE() : Bool {
    return check(THREE);
  }
  public static inline function CHECK_FOUR() : Bool {
    return check(FOUR);
  }
  public static inline function CHECK_FIVE() : Bool {
    return check(FIVE);
  }
  public static inline function CHECK_SIX() : Bool {
    return check(SIX);
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
  public static inline function CHECK_NEXT() : Bool {
    return check(NEXT);
  }

  public static var CHECK_NUMBERS : Array<Dynamic> = [CHECK_ONE, CHECK_TWO, CHECK_THREE, CHECK_FOUR, CHECK_FIVE, CHECK_SIX];
}
