package test;
import common.Util;
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

    b.swapManyForward([Point.get(0,0), Point.get(0,1), Point.get(1,1), Point.get(1,0)]);
    assertArrayEquals([sink2, sink], b.getSinks());
    assertArrayEquals([source2, source], b.getSources());
  }

  public function testLighting() {
    var b : Board = new Board(5,5);

    b.set(0,0,new Source().addColor(Color.RED));

    assertArrayEquals(Util.arrayOf(Color.RED, Hex.SIDES), b.get(0,0).getLightOutArray());

    b.relight();
    assertArrayEquals(Util.arrayOf(Color.RED, Hex.SIDES), b.get(0,0).getLightOutArray());

    b.set(0,1,new Prism().addConnector(5,1,Color.RED));
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Hex.SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));

    b.set(0,2,new Prism().addConnector(4,2,Color.RED).addConnector(4,3,Color.RED));
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Hex.SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));
    assertEquals(Color.RED, b.get(0,2).getLightIn(4));
    assertEquals(Color.RED, b.get(0,2).getLightOut(2));
    assertEquals(Color.RED, b.get(0,2).getLightOut(3));

//    b.get(0,1).rotateClockwise();
//    b.relight();
//
//    assertArrayEquals(Util.arrayOf(Color.RED, Hex.SIDES), b.get(0,0).getLightOutArray());
//    assertArrayEquals([], b.get(0,1).getLightInArray());
//    assertEquals(Color.NONE, b.get(0,1).getLightOut(1));
//    assertEquals(Color.NONE, b.get(0,2).getLightIn(4));
//    assertEquals(Color.NONE, b.get(0,2).getLightOut(2));
//    assertEquals(Color.NONE, b.get(0,2).getLightOut(3));
  }
}
