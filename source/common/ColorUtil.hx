package common;
import flixel.util.FlxColor;
class ColorUtil {
  private function new() {
    throw "Cannont Instantiate ColorUtil";
  }

  /**
   * Returns true if the two colors are compatable.
   * If either is NONE, returns false (nothing is compatable with NONE)
   * If either is ANY, returns true (everything asside from NONE is compatable with ANY)
   * Otherwise, returns true if they match (Other colors are only compatable with themselves)
   */

  public static function areCompatable(c1 : Color, c2 : Color) : Bool {
    if (c1 == null || c2 == null) {
      return false;
    }
    if (Type.enumConstructor(c1) == "NONE" || Type.enumConstructor(c2) == "NONE") {
      return false;
    }
    if (Type.enumConstructor(c1) == "ANY" || Type.enumConstructor(c2) == "ANY") {
      return true;
    }
    return Type.enumConstructor(c1) == Type.enumConstructor(c2);
  }

  public static function toFlxColor(c : Color, isLit : Bool = false) : FlxColor {
    var darknessFactor = 0.4;
    if (isLit) {
      switch(c) {
        case Color.RED: return FlxColor.RED;
        case Color.BLUE: return FlxColor.BLUE;
        case Color.YELLOW: return FlxColor.YELLOW;
        case Color.GREEN: return FlxColor.GREEN;
        case Color.NONE: return FlxColor.GRAY;
        case Color.ANY: return FlxColor.WHITE;
      }
    } else {
      switch(c) {
        case Color.RED: return FlxColor.RED.getDarkened(darknessFactor);
        case Color.BLUE: return FlxColor.BLUE.getDarkened(darknessFactor);
        case Color.YELLOW: return FlxColor.YELLOW.getDarkened(darknessFactor);
        case Color.GREEN: return FlxColor.GREEN.getDarkened(darknessFactor);
        case Color.NONE: return FlxColor.GRAY;
        case Color.ANY: return FlxColor.WHITE.getDarkened(darknessFactor);
      }
    }
  }

  public static function toString(c : Color) {
    return Std.string(c);
  }
}
