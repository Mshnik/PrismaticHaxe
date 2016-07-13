package ;
class Util {
  private function new() {
  }

  /** A mathematically correct mod operator, that returns in the range [0,b) */
  public static function mod(a : Int, b : Int) : Int {
    return ((a%b)+b)%b;
  }
}
