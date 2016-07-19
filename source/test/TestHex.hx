package test;

import game.Color;
import common.Util;
import common.Point;
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

  public function testLightInLightOut() {
    var h = SimpleHex.create();

    var expectedLight : Array<Color> = Util.arrayOf(Color.NONE, Hex.SIDES);

    var arr = h.addLightIn(0, Color.RED);
    expectedLight[0] = Color.RED;
    assertArrayEquals([0], arr);
    assertArrayEquals(expectedLight, h.getLightInArray());
    assertArrayEquals(expectedLight, h.getLightOutArray());

    arr = h.addLightIn(0,Color.BLUE);
    expectedLight[0] = Color.BLUE;
    assertArrayEquals([0], arr);
    assertArrayEquals(expectedLight, h.getLightInArray());
    assertArrayEquals(expectedLight, h.getLightOutArray());

    arr = h.addLightIn(1,Color.YELLOW);
    expectedLight[1] = Color.YELLOW;
    assertArrayEquals([1], arr);
    assertArrayEquals(expectedLight, h.getLightInArray());
    assertArrayEquals(expectedLight, h.getLightOutArray());

    arr = h.resetLight();
    expectedLight[0] = Color.NONE;
    expectedLight[1] = Color.NONE;
    assertArrayEquals([0, 1], arr);
    assertArrayEquals(expectedLight, h.getLightInArray());
    assertArrayEquals(expectedLight, h.getLightOutArray());
  }

}
