package common;

/**
 * Implementing classes have an equals method on the type T, should be the implementing type
 *  Standard rules for equals apply.
 *  As a typedef, now Contravariant on argument type.
 **/
typedef Equitable<T> = {
  public function equals(x : T) : Bool;
}

/** Enum wrapper for Equitable or not. Extend upon by the below abstract */
private enum EquitableEnum<T>{
  Equit(v:Equitable<T>);
  NonEquit(v:Dynamic);
}

/** Abstract wrapper that handles checking if the wrapped generic type is Equitable */
private abstract EquitableWrapper<T>(EquitableEnum<T>) from EquitableEnum<T> to EquitableEnum<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromEquit<T>(v:Equitable<T>):EquitableWrapper<T>{
    return EquitableEnum.Equit(v);
  }
  @:from static public function fromNonEquit<T>(v:Dynamic):EquitableWrapper<T>{
    return EquitableEnum.NonEquit(v);
  }
}

/** Utilities for Equitables. Can be imported with 'using' for inline use */
class EquitableUtils {

  /** Performs a nullsafe equity check on the two arguments */
  public static function equalsSafe<X : Equitable<X>>(x1 : X, x2 : X) : Bool {
    return (x1 == null && x2 == null) || (x1 != null && x2 != null && x1.equals(x2));
  }

  /** Performs an equity check if possible, otherwise checks equality.
   * Can pass in two T instances, the first will automatically be wrapped into a EquitableWrapper.
   **/
  public static function equalsFull<T>(t : EquitableWrapper<T>, t2 : T) : Bool {
    switch(t){
      case EquitableEnum.Equit(v) :
        //trace("Got equitable " + v);
        return (v == null && t2 == null) || (v != null && t2 != null && v.equals(t2));
      case EquitableEnum.NonEquit(v) :
        //trace("Got nonequitable " + v);
        return v == t2;
    }
  }

  /** Returns an equality function for the given type. Nulls are treated as equal
   * Non-nulls can't be equal to a null.
   **/
  public static function equalsFunc<X : Equitable<X>>(type : Class<X>) : X -> X -> Bool {
    return equalsSafe;
  }
}
