package test;
import model.Sink;
import model.Source;
import model.Prism;
import model.Rotator;
class TestRotator extends TestCase {

  public function testEquals() {
    assertEquitable(new Rotator().asHex(), new Rotator().asHex());
    assertNotEquitable(new Rotator().asHex(), new Prism().asHex());
    assertNotEquitable(new Rotator().asHex(), new Source().asHex());
    assertNotEquitable(new Rotator().asHex(), new Sink().asHex());
  }

}
