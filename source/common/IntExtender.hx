package common;
class IntExtender {

  /** A mathematically correct mod operator, that returns in the range [0,b) */
  public static inline function mod(a : Int, b : Int) : Int {
    if (b <= 0) throw "Bad mod base " + b;
    return ((a % b) + b) % b;
  }

}
