import flash.Lib;
import test.*;

class TestMain {

  public function new() {
    trace("");
    trace("Running Tests");
    var r = new haxe.unit.TestRunner();

    r.add(new TestUtil());
    r.add(new TestIntExtender());
    r.add(new TestArrayExtention());
    r.add(new TestPoint());
    r.add(new TestArray2D());
    r.add(new TestColors());
    r.add(new TestHex());
    r.add(new TestPrism());
    r.add(new TestSource());
    r.add(new TestSink());
    r.add(new TestRotator());
    r.add(new TestScore());
    r.add(new TestBoard());
    r.add(new TestXMLParser());

    r.run();
    trace(r.result);

    haxe.Timer.delay(quit, 1000);
  }

  function quit() {
    #if flash
      Lib.fscommand("quit");
    #else
      Sys.exit(0);
    #end
  }
}
