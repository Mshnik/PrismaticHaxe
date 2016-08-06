package common;

/**
 * Implementing classes have an equals method on the type T, should be the implementing type
 *  Standard rules for equals apply.
 *  As a typedef, now Covariant
 **/
typedef Equitable<T> = {
  public function equals(t : T) : Bool;
}

private enum EquitableEnum<T> {
  Equit(val : Equitable<T>);
  NonEquit(val : Dynamic);
}

/** Abstract wrapper that handles checking if the wrapped generic type is Equitable */
private abstract EquitableWrapper<T>(EquitableEnum<T>) from EquitableEnum<T> to EquitableEnum<T>{
  public function new(t) {
    this = t;
  }

  @:from
  public static function fromEquitable<T>(t : Equitable<T>) : EquitableWrapper<T> {
    return EquitableEnum.Equit(t);
  }

  @:from
  public static function fromNonEquitable<T>(t : T) : EquitableWrapper<T> {
    return EquitableEnum.NonEquit(t);
  }
}

/** Utilities for Equitables. Can be imported with 'using' for inline use */
class EquitableUtils {

  /** Performs a nullsafe equity check on the two arguments */
  public static function equalsSafe<X : Equitable<X>>(x1 : X, x2 : X) : Bool {
    return (x1 == null && x2 == null) || (x1 != null && x2 != null && x1.equals(x2));
  }

  /** Performs an equity check if possible, otherwise checks equality */
  public static inline function equalsFull<X>(x1 : X, x2 : X) : Bool {
    if (x1 == null && x2 == null) return true;
    var wrap : EquitableWrapper<X> = x1;
    trace(wrap);
    switch(wrap) {
      case EquitableEnum.Equit(v) : return x1 != null && x2 != null && v.equals(x2);
      case EquitableEnum.NonEquit(v) : return v == x2;
    }
  }

  /** Returns an equality function for the given type. Nulls are treated as equal
   * Non-nulls can't be equal to a null.
   **/
  public static function equalsFunc<X : Equitable<X>>(type : Class<X>) : X -> X -> Bool {
    return equalsSafe;
  }
}
