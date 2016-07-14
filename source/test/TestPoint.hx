package test;

import game.Point;
class TestPoint extends TestCase {

  private function checkPoint(row : Int, col : Int, actual : Point) {
    assertEquals(row, actual.row);
    assertEquals(col, actual.col);
    assertEquals("(" + row + "," + col + ")", actual.toString());
    assertEquals(Point.get(row, col), actual);
  }

  public function testCreation() {
    checkPoint(0, 0, Point.get(0, 0));
    checkPoint(2, 3, Point.get(2, 3));
    checkPoint(-1, -1, Point.get(-1, -1));
    checkPoint(10, -15, Point.get(10, -15));
  }

  public function testMath() {
    var p : Point = Point.get(1, 2);
    var p2 : Point = Point.get(3, 4);
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


}
