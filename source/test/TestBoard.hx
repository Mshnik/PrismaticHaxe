package test;

import game.Point;
import game.Hex;
import game.Board;
class TestBoard extends TestCase {

  public function testCreation() {
    var b = new Board();
    assertEquals(0, b.getHeight());
    assertEquals(0, b.getWidth());
    assertArrayEquals([], b.getBoard());
  }

  public function testAddRowAndCol() {
    var b = new Board();
    b.addRowTop();
    assertEquals(1, b.getHeight());
    assertEquals(0, b.getWidth());
    assertArrayEquals([[]], b.getBoard());
    b.addColRight();
    assertEquals(1, b.getHeight());
    assertEquals(1, b.getWidth());
    assertArrayEquals([[null]], b.getBoard());
    b.addRowTop();
    assertEquals(2, b.getHeight());
    assertEquals(1, b.getWidth());
    assertArrayEquals([[null], [null]], b.getBoard());
    b.addColRight();
    assertEquals(2, b.getHeight());
    assertEquals(2, b.getWidth());
    assertArrayEquals([[null, null], [null, null]], b.getBoard());

    var b2 = new Board();
    b2.ensureSize(2,2);
    assertArrayEquals([[null, null], [null, null]], b2.getBoard());
  }

  public function testHexOnBoard() {
    var b = new Board();
    b.ensureSize(5,5);

    var h : Hex = new SimpleHex();
    b.set(0,0,h);
    assertEquals(h, b.get(0,0));
    b.set(0,0,null);
    assertEquals(null, b.get(0,0));
    b.set(0,0,h);
    b.remove(0,0);
    assertEquals(null, b.get(0,0));

    b.setAt(Point.get(0,0),h);
    assertEquals(h, b.getAt(Point.get(0,0)));
    b.removeAt(Point.get(0,0));
    assertEquals(null, b.get(0,0));
  }

  public function testHexSwapping() {
    var h : Hex = new SimpleHex();
    var h2 : Hex = new SimpleHex();
    var h3 : Hex = new SimpleHex();

    var p = Point.get(0,0);
    var p2 = Point.get(1,0);
    var p3 = Point.get(1,1);
    var p4 = Point.get(0,1);

    var b = new Board();
    b.ensureSize(2,2);
    b.setAt(p,h);
    b.setAt(p2,h2);

    //At this point hexes 1 and 2 at their correct locations

    assertEquals(h, b.getAt(p));
    assertEquals(h2, b.getAt(p2));

    b.swap(p,p2);

    assertEquals(h, b.getAt(p2));
    assertEquals(h2, b.getAt(p));

    b.swap(p,p2);
    b.setAt(p3,h3);

    //At this point, all hexes at their correct locations

    var arr = [p,p2,p3,p4];
    b.swapManyForward(arr);

    assertArrayEquals([p,p2,p3,p4], arr);
    assertEquals(h, b.getAt(p2));
    assertEquals(h2, b.getAt(p3));
    assertEquals(h3, b.getAt(p4));
    assertEquals(null, b.getAt(p));

    b.swapManyBackward(arr);
    assertArrayEquals([p,p2,p3,p4], arr);
    assertEquals(h, b.getAt(p));
    assertEquals(h2, b.getAt(p2));
    assertEquals(h3, b.getAt(p3));
    assertEquals(null, b.getAt(p4));

    //At this point, all hexes at their correct locations
  }

}
