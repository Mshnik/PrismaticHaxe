package test;
class TestSource extends TestCase {

  public function testConstructionAndAddColors() {
    var s = new Source();
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
    var s = new Source();

    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.NONE, s.getLightOut(i));
    }

    s.addColor(Color.RED);
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addColor(Color.BLUE);
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.useNextColor();
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.BLUE, s.getLightOut(i));
    }

    s.useNextColor();
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addLightIn(0, Color.RED);
    assertEquals(Color.RED, s.getLightIn(0));
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.addLightIn(1,Color.YELLOW);
    assertEquals(Color.RED, s.getLightIn(0));
    assertEquals(Color.YELLOW, s.getLightIn(1));
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }

    s.rotateClockwise();
    assertEquals(Color.RED, s.getLightIn(1));
    assertEquals(Color.YELLOW, s.getLightIn(2));
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.RED, s.getLightOut(i));
    }
  }

  public function testEquals() {
    assertEquitable(new Source().asHex(), new Source().asHex());
    assertNotEquitable(new Source().asHex(), new Prism().asHex());
    assertNotEquitable(new Source().asHex(), new Sink().asHex());
    assertNotEquitable(new Source().asHex(), new Rotator().asHex());

    var s = new Source();
    var s2 = new Source();

    s.addColor(Color.RED);
    s2.addColor(Color.RED);
    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.addColor(Color.BLUE);
    assertNotEquitable(s, s2);
    assertNotEquitable(s2, s);

    s2.addColor(Color.BLUE);
    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.useNextColor();
    assertNotEquitable(s, s2);
    assertNotEquitable(s2, s);

    s2.useNextColor();
    assertEquitable(s, s2);
    assertEquitable(s2, s);
  }
}
