package common;

/** Partial application helpers for functions.
 * Probably not super fast, so only for use in testing and temp fixes.
 *
 * Unfortunately track names are necessary because of Haxe's lack of method overloading.
 * The A track is for functions without a return (return type of Void)
 * and the B track is for functions with a return (non-void).
 *
 * Correct usage
 *
 * var f : A -> B -> C -> Void
 * var f2 = f.apply3A(a) : B -> C -> Void
 * var f3 = f2.apply2A(b) : C -> Void
 * var f4 = f3.apply1A(c) : Void -> Void
 * var f5 = f.apply3A(a).apply2A(b).apply1A(c)
 * f4 equals f5.
 *
 * var f : A -> B -> C -> D
 * var f2 = f.apply3B(a) : B -> C -> D
 * var f3 = f2.apply2B(b) : C -> D
 * var f4 = f3.apply1B(c) : Void -> D
 * var f5 = f.apply3B(a).apply2B(b).apply1B(c)
 * f4 equals f5.
 *
 **/
class FunctionExtender {

  @:generic public static inline function discardReturn<R>(func : Void -> R) : Void -> Void {
    return function() : Void {
      func();
    }
  }

  @:generic public static inline function apply1A<T>(func : T -> Void, t : T) : Void -> Void {
    return function() : Void {
      func(t);
    }
  }

  @:generic public static inline function apply1B<T,R>(func : T -> R, t : T) : Void -> R {
    return function() : R {
      return func(t);
    }
  }

  @:generic public static inline function apply2A<T,S>(func : T -> S -> Void, t : T) : S -> Void {
    return function(s : S) : Void {
      return func(t,s);
    }
  }

  @:generic public static inline function apply2B<T,S,R>(func : T -> S -> R, t : T) : S -> R {
    return function(s : S) : R {
      return func(t,s);
    }
  }

  @:generic public static inline function apply3A<T,S,Q>(func : T -> S -> Q -> Void, t : T) : S -> Q -> Void {
    return function(s : S, q : Q) : Void {
      return func(t,s,q);
    }
  }

  @:generic public static inline function apply3B<T,S,Q,R>(func : T -> S -> Q -> R, t : T) : S -> Q -> R {
    return function(s : S, q : Q) : R {
      return func(t,s,q);
    }
  }

}
