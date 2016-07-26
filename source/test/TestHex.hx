package test;

import common.Color;
import common.Util;
import common.Point;
import model.Hex;

using common.IntExtender;

class TestHex extends TestCase {

  private inline function checkValidOrientation(h : Hex) {
    assertTrue(h.orientation >= 0 && h.orientation < Util.HEX_SIDES);
  }

  public function testIDs() {
    var h = SimpleHex.create();
    assertEquals(1, h.id);

    var h2 = SimpleHex.create();
    assertEquals(1, h.id);
    assertEquals(2, h2.id);

    var h3 = SimpleHex.create();
    assertEquals(1, h.id);
    assertEquals(2, h2.id);
    assertEquals(3, h3.id);

    Hex.resetIDs();

    var h4 = SimpleHex.create();
    assertEquals(1, h.id);
    assertEquals(2, h2.id);
    assertEquals(3, h3.id);
    assertEquals(1, h4.id);

    var arr = [h2,h3,h];
    arr.sort(function(a,b){return a.id - b.id;});
    assertArrayEquals([h,h2,h3], arr);
  }

  public function testRotation() {
    var h : SimpleHex = new SimpleHex();
    assertEquals(0, h.orientation);
    assertEquals(0, h.rotations);

    for (i in 1...14) {
      h.orientation = i;
      checkValidOrientation(h);
      assertEquals(i.mod(Util.HEX_SIDES), h.orientation);
      assertEquals(i, h.rotations);

      //Check that setting orientation to existing orientation doesn't call onRotate
      h.orientation = h.orientation;
      assertEquals(i, h.rotations);
    }

    var h2 = new SimpleHex();
    for (i in 1...14) {
      h2.rotateCounterClockwise();
      checkValidOrientation(h2);
      assertEquals(i.mod(Util.HEX_SIDES), h2.orientation);
      assertEquals(i, h2.rotations);
    }

    var h3 = new SimpleHex();
    for (i in 1...14) {
      h3.rotateClockwise();
      checkValidOrientation(h3);
      assertEquals((-i).mod(Util.HEX_SIDES), h3.orientation);
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

    var expectedLight : Array<Color> = Util.arrayOf(Color.NONE, Util.HEX_SIDES);

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
