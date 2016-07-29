package test;
import model.Sink;
import model.Source;
import model.Prism;
import model.Rotator;
class TestRotator extends TestCase {

  public function testEquals() {
    assertTrue(new Rotator().equals(new Rotator()));
    assertFalse(new Rotator().equals(new Prism()));
    assertFalse(new Rotator().equals(new Source()));
    assertFalse(new Rotator().equals(new Sink()));
  }

}
