package test;

import model.*;
import common.Color;
import common.Util;
import common.Point;

using common.IntExtender;
using common.FunctionExtender;

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

    shouldFail(h.set_id.apply1B(3));
    shouldFail(h.set_id.apply1B(-3));
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

  public function testOrientationConverters() {
    var h = SimpleHex.create();


    for(i in 0...Util.HEX_SIDES) {
      assertEquals(i, h.correctForOrientation(i));
      assertEquals(i, h.uncorrectForOrientation(i));
    }

    var p = Point.get(0,1);
    assertEquals(p, h.correctPtForOrientation(p));
    assertEquals(p, h.uncorrectPtForOrientation(p));

    h.rotateClockwise();
    for(i in 0...Util.HEX_SIDES) {
      assertEquals((i-1).mod(Util.HEX_SIDES), h.correctForOrientation(i));
      assertEquals(i, h.uncorrectForOrientation(h.correctForOrientation(i)));
    }

    var p2 = Point.get(5,0);
    assertEquals(p2, h.correctPtForOrientation(p));
    assertEquals(p, h.uncorrectPtForOrientation(h.correctPtForOrientation(p)));

    h.rotateCounterClockwise();
    h.rotateCounterClockwise();
    for(i in 0...Util.HEX_SIDES) {
      assertEquals((i+1).mod(Util.HEX_SIDES), h.correctForOrientation(i));
      assertEquals(i, h.uncorrectForOrientation(h.correctForOrientation(i)));
    }

    var p3 = Point.get(1,2);
    assertEquals(p3, h.correctPtForOrientation(p));
    assertEquals(p, h.uncorrectPtForOrientation(h.correctPtForOrientation(p)));
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
    shouldFail(new Hex().addLightIn.apply2B(0).apply1B(Color.RED));

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

  public function testConversion() {

    assertTrue(new Prism().isPrism());
    assertFalse(new Source().isPrism());
    shouldFail(new Source().asPrism.discardReturn());
    assertFalse(new Sink().isPrism());
    shouldFail(new Sink().asPrism.discardReturn());
    assertFalse(new Rotator().isPrism());
    shouldFail(new Rotator().asPrism.discardReturn());

    assertFalse(new Prism().isSource());
    shouldFail(new Prism().asSource.discardReturn());
    assertTrue(new Source().isSource());
    assertFalse(new Sink().isSource());
    shouldFail(new Sink().asSource.discardReturn());
    assertFalse(new Rotator().isSource());
    shouldFail(new Rotator().asSource.discardReturn());

    assertFalse(new Prism().isSink());
    shouldFail(new Prism().asSink.discardReturn());
    assertFalse(new Source().isSink());
    shouldFail(new Source().asSink.discardReturn());
    assertTrue(new Sink().isSink());
    assertFalse(new Rotator().isSink());
    shouldFail(new Rotator().asSink.discardReturn());

    assertFalse(new Prism().isRotator());
    shouldFail(new Prism().asRotator.discardReturn());
    assertFalse(new Source().isRotator());
    shouldFail(new Source().asRotator.discardReturn());
    assertFalse(new Sink().isRotator());
    shouldFail(new Sink().asRotator.discardReturn());
    assertTrue(new Rotator().isRotator());
  }

  public function testEquals() {
    var h1 = SimpleHex.create();
    var h2 = SimpleHex.create();

    assertFalse(h1.equals(null));

    for(i in 0...Util.HEX_SIDES) {
      assertTrue(h1.equals(h2));
      assertTrue(h2.equals(h1));

      h1.rotateCounterClockwise();
      h2.rotateCounterClockwise();
    }

    h1.rotateClockwise();
    for(i in 0...Util.HEX_SIDES) {
      assertFalse(h1.equals(h2));
      assertFalse(h2.equals(h1));

      h1.rotateCounterClockwise();
      h2.rotateCounterClockwise();
    }
  }

}
