package common;

import common.Equitable.EquitableUtils;

class Pair<A,B> {
  private var _1 : A;
  private var _2 : B;

  public static inline function of<A,B>(a : A, b : B) {
    return new Pair<A,B>(a,b);
  }

  private function new(a : A, b : B) {
    _1 = a;
    _2 = b;
  }

  public function copy() : Pair<A,B> {
    return of(_1,_2);
  }

  public inline function getFirst() : A {
    return _1;
  }

  public inline function getSecond() : B {
    return _2;
  }

  public function equals(p : Pair<A,B>) : Bool {
    return p != null && EquitableUtils.equalsFull(_1, p._1) && EquitableUtils.equalsFull(_2, p._2);
  }

  public function toString() : String {
    return "(" + _1 + "," + _2 + ")";
  }
}
