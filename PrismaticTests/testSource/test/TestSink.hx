package test;
class TestSink extends TestCase {

  public function testConstructionAndLighting() {
    var s = new Sink();
    assertEquals(Color.NONE, s.getCurrentColor());

    s.addLightIn(0, Color.RED);
    assertEquals(Color.RED, s.getCurrentColor());

    s.addLightIn(1, Color.BLUE);
    assertEquals(Color.RED, s.getCurrentColor());

    s.addLightIn(2, Color.RED);
    assertEquals(Color.RED, s.getCurrentColor());

    s.resetLight();
    assertEquals(Color.NONE, s.getCurrentColor());
  }

  public function testEquals() {
    assertEquitable(new Sink().asHex(), new Sink().asHex());
    assertNotEquitable(new Sink().asHex(), new Prism().asHex());
    assertNotEquitable(new Sink().asHex(), new Source().asHex());
    assertNotEquitable(new Sink().asHex(), new Rotator().asHex());
  }

}
