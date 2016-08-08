package test;

import common.Point;
class TestPoint extends TestCase {

  private static inline function get(row : Int, col : Int) : Point {
    return Point.get(row, col);
  }

  private static inline function fromString(s : String) : Point {
    return Point.fromString(s);
  }

  private function checkPoint(row : Int, col : Int, actual : Point) {
    assertEquals(row, actual.row);
    assertEquals(col, actual.col);
    assertEquals("(" + row + "," + col + ")", actual.toString());
    assertEquals(get(row, col), actual);
  }

  public function testFromString() {
    checkPoint(0,0,fromString("(0,0)"));
    checkPoint(0,1,fromString("(0,1)"));
    checkPoint(0,-1,fromString("(0,-1)"));
    checkPoint(-3,-2,fromString("(-3,-2)"));
    checkPoint(3,-2,fromString("(3,-2)"));
  }

  public function testCreation() {
    checkPoint(0, 0, get(0, 0));
    checkPoint(2, 3, get(2, 3));
    checkPoint(-1, -1, get(-1, -1));
    checkPoint(10, -15, get(10, -15));
  }

  public function testEquality() {
    assertEquitable(get(0,0), get(0,0));
    assertEquitable(get(1,0), get(1,0));
    assertEquitable(get(0,2), get(0,2));
    assertEquitable(get(0,0), get(0,0));
    assertEquitable(get(-1,0), get(-1,0));
    assertEquitable(get(0,-2), get(0,-2));
    assertNotEquitable(get(0,1), get(0,0));
    assertNotEquitable(get(1,0), get(0,0));
    assertNotEquitable(get(1,1), get(0,0));
  }

  public function testMath() {
    var p : Point = get(1, 2);
    var p2 : Point = get(3, 4);
    checkPoint(4, 6, p.add(p2));
    checkPoint(1, 2, p);
    checkPoint(3, 4, p2);
    checkPoint(2, 2, p2.subtract(p));
    checkPoint(1, 2, p);
    checkPoint(3, 4, p2);

    assertEquals(11, p.dot(p2));
    assertEquals(11, p2.dot(p));
    checkPoint(1, 2, p);
    checkPoint(3, 4, p2);
  }

  public function testUnits() {
    assertEquals(Point.ZERO, get(0,0));
    assertEquals(Point.UP, get(-1,0));
    assertEquals(Point.DOWN, get(1,0));
    assertEquals(Point.LEFT, get(0,-1));
    assertEquals(Point.RIGHT, get(0,1));
    assertEquals(Point.UPLEFT, get(-1,-1));
    assertEquals(Point.UPRIGHT, get(-1,1));
    assertEquals(Point.DOWNLEFT, get(1,-1));
    assertEquals(Point.DOWNRIGHT, get(1,1));

    var p = Point.ZERO;
    var p2 = Point.UP;
    var p3 = Point.DOWN;
    var p4 = Point.LEFT;
    var p5 = Point.RIGHT;
    var p6 = Point.UPLEFT;
    var p7 = Point.UPRIGHT;
    var p8 = Point.DOWNLEFT;
    var p9 = Point.DOWNRIGHT;

    Point.clearPool();

    assertEquals(Point.ZERO, p);
    assertEquals(Point.UP, p2);
    assertEquals(Point.DOWN, p3);
    assertEquals(Point.LEFT, p4);
    assertEquals(Point.RIGHT, p5);
    assertEquals(Point.UPLEFT, p6);
    assertEquals(Point.UPRIGHT, p7);
    assertEquals(Point.DOWNLEFT, p8);
    assertEquals(Point.DOWNRIGHT, p9);
  }

  public function testNeighbors() {
    var p = get(2,2);
    assertArrayEquals([get(1,2), get(1,3),get(2,3), get(3,2), get(2,1), get(1,1)], p.getNeighbors());

    var p2 = get(4,5);
    assertArrayEquals([get(3,5), get(4,6),get(5,6), get(5,5), get(5,4), get(4,4)], p2.getNeighbors());
  }

  public function testNeighborAngle() {
    var i = 0;
    for(p in Point.ZERO.getNeighbors()) {
      assertEquals(i, Point.ZERO.angleTo(p));
      i += 60;
    }

    i = 0;
    for(p in Point.RIGHT.getNeighbors()) {
      assertEquals(i, Point.RIGHT.angleTo(p));
      i += 60;
    }
  }

}
