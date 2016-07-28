package common;
import haxe.ds.StringMap;
class Point {

  private static var allocatedPoints : StringMap<Point> = new StringMap<Point>();
  private static var currentPoolSize = 0;
  private static var MAX_POOL_SIZE = 256;

  public static var ZERO : Point = get(0,0);
  public static var UP : Point = get(-1,0);
  public static var DOWN : Point = get(1,0);
  public static var LEFT : Point = get(0,-1);
  public static var RIGHT : Point = get(0,1);
  public static var UPLEFT : Point = get(-1,-1);
  public static var UPRIGHT : Point = get(-1,1);
  public static var DOWNLEFT : Point = get(1,-1);
  public static var DOWNRIGHT : Point = get(1,1);

  public static var NEIGHBOR_DELTAS : Array<Array<Point>> = [
    [Point.UP, Point.UPRIGHT, Point.RIGHT, Point.DOWN, Point.LEFT, Point.UPLEFT],
    [Point.UP, Point.RIGHT, Point.DOWNRIGHT, Point.DOWN, Point.DOWNLEFT, Point.LEFT]
  ];

  public static inline function get(row : Int, col : Int) : Point {
    var s = createString(row, col);
    if (allocatedPoints.exists(s)) {
      return allocatedPoints.get(s);
    }
    return new Point(row, col);
  }

  public static inline function fromString(s : String) : Point {
    var i = s.indexOf(",");
    return get(Std.parseInt(s.substring(1,i)), Std.parseInt(s.substring(i+1)));
  }

  public static inline function clearPool() : Void {
    allocatedPoints = new StringMap<Point>();

    allocatedPoints.set(createStringOf(ZERO), ZERO);
    allocatedPoints.set(createStringOf(UP), UP);
    allocatedPoints.set(createStringOf(DOWN), DOWN);
    allocatedPoints.set(createStringOf(LEFT), LEFT);
    allocatedPoints.set(createStringOf(RIGHT), RIGHT);
    allocatedPoints.set(createStringOf(UPLEFT), UPLEFT);
    allocatedPoints.set(createStringOf(UPRIGHT), UPRIGHT);
    allocatedPoints.set(createStringOf(DOWNRIGHT), DOWNRIGHT);
    allocatedPoints.set(createStringOf(DOWNLEFT), DOWNLEFT);
  }

  public var row(default, null) : Int;
  public var col(default, null) : Int;

  private function new(row : Int, col : Int) {
    this.row = row;
    this.col = col;
    if (currentPoolSize < MAX_POOL_SIZE) {
      allocatedPoints.set(toString(), this);
      currentPoolSize++;
    }
  }

  public inline function add(p : Point) : Point {
    return get(row + p.row, col + p.col);
  }

  public inline function subtract(p : Point) : Point {
    return get(row - p.row, col - p.col);
  }

  public inline function dot(p : Point) : Int {
    return row * p.row + col * p.col;
  }

  private static inline function createStringOf(p : Point) : String {
    return createString(p.row, p.col);
  }

  private static inline function createString(row : Int, col : Int) : String {
    return "(" + row + "," + col + ")";
  }

  public inline function equals(p : Point) : Bool {
    return row == p.row && col == p.col;
  }

  public inline function toString() : String {
    return createString(row, col);
  }

  /** Returns the locations considered neighboring the given point.
   * May include points that will be OOB in an Array2D, so should be filtered before applied.
   **/
  public inline function getNeighbors() : Array<Point> {
    return NEIGHBOR_DELTAS[col%2].map(add);
  }

}
