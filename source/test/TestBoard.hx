package test;
import common.Point;
import model.*;
class TestBoard extends TestCase {

  public function testSinkAndSourceRetention() {
    var b = new Board().ensureSize(2,2);

    assertArrayEquals([], b.getSinks());
    assertArrayEquals([], b.getSources());

    var source = Std.instance(b.set(0,0,new Source()), Source);
    assertArrayEquals([], b.getSinks());
    assertArrayEquals([source], b.getSources());

    var sink = Std.instance(b.set(1,0,new Sink()), Sink);
    assertArrayEquals([sink], b.getSinks());
    assertArrayEquals([source], b.getSources());

    b.swap(Point.get(0,0), Point.get(1,0));
    assertArrayEquals([sink], b.getSinks());
    assertArrayEquals([source], b.getSources());

    var source2 = Std.instance(b.set(0,1,new Source()), Source);
    assertArrayEquals([sink], b.getSinks());
    assertArrayEquals([source, source2], b.getSources());

    var sink2 = Std.instance(b.set(1,1,new Sink()), Sink);
    assertArrayEquals([sink, sink2], b.getSinks());
    assertArrayEquals([source, source2], b.getSources());

//    b.swapManyForward([Point.get(0,0), Point.get(0,1), Point.get(1,1), Point.get(1,0)]);
//    assertArrayEquals([sink, sink2], b.getSinks());
//    assertArrayEquals([source, source2], b.getSources());
  }

}
