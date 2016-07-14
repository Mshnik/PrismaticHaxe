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

    var h = SimpleHex.create();
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
    var h = SimpleHex.create();
    var h2 = SimpleHex.create();
    var h3 = SimpleHex.create();

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

  public function testShift() {
    var b = new Board();
    b.ensureSize(3,3);

    var h = b.set(0,0,SimpleHex.create());
    var h2 = b.set(0,1,SimpleHex.create());
    var h3 = b.set(1,1,SimpleHex.create());
    var h4 = b.set(1,0,SimpleHex.create());

    b.shift(1,1);
    assertEquals(null, b.get(0,0));
    assertEquals(null, b.get(0,1));
    assertEquals(null, b.get(0,2));
    assertEquals(null, b.get(1,0));
    assertEquals(null, b.get(2,0));
    assertEquals(h, b.get(1,1));
    assertEquals(h2, b.get(1,2));
    assertEquals(h3, b.get(2,2));
    assertEquals(h4, b.get(2,1));

    b.shift(-1, -1);
    assertEquals(h, b.get(0,0));
    assertEquals(h2, b.get(0,1));
    assertEquals(h3, b.get(1,1));
    assertEquals(h4, b.get(1,0));
    assertEquals(null, b.get(2,0));
    assertEquals(null, b.get(2,1));
    assertEquals(null, b.get(2,2));
    assertEquals(null, b.get(1,2));
    assertEquals(null, b.get(0,2));

    //Test wrapping around
    b.shift(-1,-1);
    assertEquals(h, b.get(2,2));
    assertEquals(h2, b.get(2,0));
    assertEquals(h3, b.get(0,0));
    assertEquals(h4, b.get(0,2));
    assertEquals(null, b.get(1,1));
    assertEquals(null, b.get(0,1));
    assertEquals(null, b.get(1,2));
    assertEquals(null, b.get(1,0));
    assertEquals(null, b.get(2,1));
  }

}
