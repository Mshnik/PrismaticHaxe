package test;
import game.Hex;
import game.Color;
import game.Spark;
class TestSpark extends TestCase {

  public function testConstructionAndAddColors() {
    var s = new Spark();
    assertArrayEquals([Color.NONE], s.getAvailableColors());
    assertEquals(Color.NONE, s.getCurrentColor());

    s.useNextColor();
    assertEquals(Color.NONE, s.getCurrentColor());

    s.addColor(Color.NONE);
    assertArrayEquals([Color.NONE], s.getAvailableColors());
    assertEquals(Color.NONE, s.getCurrentColor());

    s.addColor(Color.RED);
    assertArrayEquals([Color.RED], s.getAvailableColors());
    assertEquals(Color.RED, s.getCurrentColor());

    s.useNextColor();
    assertEquals(Color.RED, s.getCurrentColor());

    s.usePreviousColor();
    assertEquals(Color.RED, s.getCurrentColor());

    s.addColor(Color.RED);
    assertArrayEquals([Color.RED], s.getAvailableColors());
    assertEquals(Color.RED, s.getCurrentColor());

    s.addColor(Color.NONE);
    assertArrayEquals([Color.RED], s.getAvailableColors());
    assertEquals(Color.RED, s.getCurrentColor());

    s.addColor(Color.BLUE);
    assertArrayEquals([Color.RED, Color.BLUE], s.getAvailableColors());
    assertEquals(Color.RED, s.getCurrentColor());

    s.useNextColor();
    assertEquals(Color.BLUE, s.getCurrentColor());

    s.useNextColor();
    assertEquals(Color.RED, s.getCurrentColor());

    s.usePreviousColor();
    assertEquals(Color.BLUE, s.getCurrentColor());
  }

  public function testLightInOut() {
    var s = new Spark();

    for(i in 0...Hex.SIDES) {
      assertEquals(Color.NONE, s.getLightOut(i));
    }

    s.addColor(Color.RED);
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addColor(Color.BLUE);
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.useNextColor();
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.BLUE, s.getLightOut(i));
    }

    s.useNextColor();
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addLightIn(0, Color.RED);
    assertEquals(Color.RED, s.getLightIn(0));
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addLightIn(1,Color.YELLOW);
    assertEquals(Color.RED, s.getLightIn(0));
    assertEquals(Color.YELLOW, s.getLightIn(1));
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.rotateCounterClockwise();
    assertEquals(Color.RED, s.getLightIn(1));
    assertEquals(Color.YELLOW, s.getLightIn(2));
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }
  }
}
