package test;
import model.Sink;
import common.Color;
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

}
