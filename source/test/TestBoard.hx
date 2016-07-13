package test;

import game.Board;
class TestBoard extends TestCase {

  public function testCreation() {
    var b = new Board();
    assertEquals(0, b.getHeight());
    assertEquals(0, b.getWidth());
  }

  public function testAddRowAndCol() {
    var b = new Board();
    b.addRowTop();
    assertEquals(1, b.getHeight());
    assertEquals(0, b.getWidth());
    b.addColRight();
    assertEquals(1, b.getHeight());
  }
}
