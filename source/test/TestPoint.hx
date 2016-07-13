package test;

import game.Point;
class TestPoint extends TestCase {

  private function checkPoint(row : Int, col : Int, actual : Point) {
    assertEquals(row, actual.row);
    assertEquals(col, actual.col);
    assertEquals("(" + row + "," + col + ")", actual.toString());
    assertEquals(Point.get(row,col), actual);
  }

  public function testCreation() {
    checkPoint(0,0,Point.get(0,0));
    checkPoint(2,3,Point.get(2,3));
    checkPoint(-1,-1,Point.get(-1,-1));
    checkPoint(10,-15,Point.get(10,-15));
  }


}
