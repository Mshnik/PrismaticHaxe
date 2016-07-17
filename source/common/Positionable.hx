package common;

/** A Positionable is any object that has a position in (row,col) form.
 * Implementing classes can be imutable if the setter simply throws
 */
interface Positionable {
  public var position(default,set) : Point;
}
