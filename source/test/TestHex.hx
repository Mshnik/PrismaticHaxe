package test;

import game.Point;
import game.Hex;

class TestHex extends TestCase {

  private inline function checkValidOrientation(h : Hex) {
    assertTrue(h.orientation >= 0 && h.orientation < Hex.SIDES);
  }

  public function testRotation() {
    var h : SimpleHex = new SimpleHex();
    assertEquals(0, h.orientation);
    assertEquals(0, h.rotations);

    for (i in 1...14) {
      h.orientation = i;
      checkValidOrientation(h);
      assertEquals(Util.mod(i, Hex.SIDES), h.orientation);
      assertEquals(i, h.rotations);

      //Check that setting orientation to existing orientation doesn't call onRotate
      h.orientation = h.orientation;
      assertEquals(i, h.rotations);
    }

    var h2 = new SimpleHex();
    for (i in 1...14) {
      h2.rotateClockwise();
      checkValidOrientation(h2);
      assertEquals(Util.mod(i, Hex.SIDES), h2.orientation);
      assertEquals(i, h2.rotations);
    }

    var h3 = new SimpleHex();
    for (i in 1...14) {
      h3.rotateCounterClockwise();
      checkValidOrientation(h3);
      assertEquals(Util.mod(-i, Hex.SIDES), h3.orientation);
      assertEquals(i, h3.rotations);
    }
  }

  public function testPosition() {
    var h = SimpleHex.create();
    assertEquals(Point.get(-1,-1),h.position);

    h.position = Point.get(1,1);
    assertEquals(Point.get(1,1), h.position);

    h.shift(1,1);
    assertEquals(Point.get(2,2), h.position);
  }

}
