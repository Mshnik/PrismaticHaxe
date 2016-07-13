package game;
import haxe.ds.StringMap;
class Point {

  private static var allocatedPoints : StringMap<Point> = new StringMap<Point>();
  private static var currentPoolSize = 0;
  private static var MAX_POOL_SIZE = 256;

  public static function get(row : Int, col : Int) : Point {
    var s = createString(row, col);
    if (allocatedPoints.exists(s)) {
      return allocatedPoints.get(s);
    }
    return new Point(row, col);
  }

  public static function clearPool() : Void {
    allocatedPoints = new StringMap<Point>();
  }

  public var row(default, null) : Int;
  public var col(default, null) : Int;

  private function new(row : Int, col : Int) {
    this.row = row;
    this.col = col;
    if (currentPoolSize < MAX_POOL_SIZE) {
      allocatedPoints.set(toString(),this);
      currentPoolSize++;
    }
  }

  @:op(A + B)
  public function add(p : Point) : Point {
    return get(row + p.row, col + p.col);
  }

  @:op(A - B)
  public function subtract(p : Point) : Point {
    return get(row - p.row, col - p.col);
  }

  @:op(A * B)
  public function dot(p : Point) : Int {
    return row * p.row + col * p.col;
  }

  private static inline function createString(row : Int, col : Int) : String {
    return "(" + row + "," + col + ")";
  }

  public inline function toString() : String {
    return createString(row, col);
  }

}
