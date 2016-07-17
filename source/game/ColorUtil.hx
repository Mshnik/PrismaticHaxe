package game;
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
}
