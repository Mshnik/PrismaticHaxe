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

    b.set(0,1,h);
    b.swap(Point.get(0,1),Point.get(2,3));
    assertEquals(h, b.get(2,3));
  }

}
