package common;

/**
 * Implementing classes have an equals method on the type T, should be the implementing type
 *  Standard rules for equals apply.
 **/
interface Equitable<T> {

  public function equals(t : T) : Bool;

}

class EquitableUtils {

  /** Returns an equality function for the given type. Nulls are treated as equal */
  public static function equalsFunc<X : Equitable<X>>(type : Class<X>) : X -> X -> Bool {
    return function(x1 : X, x2 : X) : Bool {
      return (x1 == null && x2 == null) || x1.equals(x2);
    }
  }


}
