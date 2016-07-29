package test;

import common.*;
import model.*;

using common.ArrayExtender;
using common.FunctionExtender;

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

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());

    b.relight();
    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());

    b.set(0,1,new Prism().addConnector(5,1,Color.RED));
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));

    b.set(0,2,new Prism().addConnector(4,2,Color.RED).addConnector(4,3,Color.RED));
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));
    assertEquals(Color.RED, b.get(0,2).getLightIn(4));
    assertEquals(Color.RED, b.get(0,2).getLightOut(2));
    assertEquals(Color.RED, b.get(0,2).getLightOut(3));

    b.get(0,1).rotateClockwise();
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(1));
    assertEquals(Color.NONE, b.get(0,2).getLightIn(4));
    assertEquals(Color.NONE, b.get(0,2).getLightOut(2));
    assertEquals(Color.NONE, b.get(0,2).getLightOut(3));

    b.set(1,2,new Prism().addConnector(0,0,Color.RED));
    b.get(0,1).rotateCounterClockwise();
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));
    assertEquals(Color.RED, b.get(0,2).getLightIn(4));
    assertEquals(Color.RED, b.get(0,2).getLightOut(2));
    assertEquals(Color.RED, b.get(0,2).getLightOut(3));
    assertEquals(Color.RED, b.get(1,2).getLightIn(0));

    //Add a second color
    b.set(1,0,new Source().addColor(Color.BLUE));
    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertArrayEquals(Util.arrayOf(Color.BLUE, Util.HEX_SIDES), b.get(1,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));
    assertEquals(Color.RED, b.get(0,2).getLightIn(4));
    assertEquals(Color.RED, b.get(0,2).getLightOut(2));
    assertEquals(Color.RED, b.get(0,2).getLightOut(3));
    assertEquals(Color.RED, b.get(1,2).getLightIn(0));

    b.set(1,1,new Prism().addConnector(5,0,Color.BLUE));
    b.get(0,1).asPrism().addConnector(3,2,Color.BLUE);

    b.relight();

    assertArrayEquals(Util.arrayOf(Color.RED, Util.HEX_SIDES), b.get(0,0).getLightOutArray());
    assertArrayEquals(Util.arrayOf(Color.BLUE, Util.HEX_SIDES), b.get(1,0).getLightOutArray());
    assertEquals(Color.RED, b.get(0,1).getLightIn(5));
    assertEquals(Color.RED, b.get(0,1).getLightOut(1));
    assertEquals(Color.RED, b.get(0,2).getLightIn(4));
    assertEquals(Color.RED, b.get(0,2).getLightOut(2));
    assertEquals(Color.RED, b.get(0,2).getLightOut(3));
    assertEquals(Color.RED, b.get(1,2).getLightIn(0));
    assertEquals(Color.BLUE, b.get(1,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(1,1).getLightOut(0));
    assertEquals(Color.BLUE, b.get(0,1).getLightIn(3));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(2));

    var b2 = new Board().ensureSize(1,2);
    b2.set(0,0,new Source().addColor(Color.BLUE));
    b2.set(0,1,new Prism().addConnector(5,1,Color.BLUE).addConnector(1,5,Color.BLUE));
    b2.relight();

    assertEquals(Color.BLUE, b2.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b2.get(0,1).getLightOut(1));

    b2.get(0,1).rotateCounterClockwise();
    b2.relight();

    assertEquals(Color.NONE, b2.get(0,1).getLightOut(0));
    assertEquals(Color.NONE, b2.get(0,1).getLightOut(4));

    b2.get(0,1).rotateCounterClockwise();
    b2.relight();

    assertEquals(Color.BLUE, b2.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b2.get(0,1).getLightOut(3));
  }

  public function testLightingWithAcceptConnections() {
    var b = new Board().ensureSize(3,3);

    b.set(0,0,new Source().addColor(Color.BLUE));
    b.set(0,1,new Prism().addConnector(5,0,Color.BLUE));

    b.relight();

    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));

    b.get(0,1).acceptConnections = false;
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.relight();
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.get(0,1).acceptConnections = true;
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.relight();
    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));
  }

  /** Returns the orientation of h. For use in mapping */
  private function getOrientation(h : Hex) {
    return h.orientation;
  }

  public function testRotator() {
    var b = new Board(3,3).fillWith(SimpleHex.create);

    //Check listeners are added correctly when put into board

    var r = new Rotator();
    assertEquals(null, r.rotationListener);

    b.set(1,1,r);
    assertTrue(r.rotationListener != null);

    b.set(1,1,null);
    assertEquals(null, r.rotationListener);

    b.set(1,1,r);
    assertTrue(r.rotationListener != null);

    b.swap(Point.get(0,0), Point.get(1,1));
    assertTrue(r.rotationListener != null);

    b.swap(Point.get(0,0), Point.get(1,1));
    assertTrue(r.rotationListener != null);

    shouldFail(b.set.apply3B(0).apply2B(1).apply1B(new Rotator()));

    // Check rotation of rotator and that orientations change with it

    var arr : Array<Hex> = Point.get(1,1).getNeighbors().map(b.getAtUnsafe);
    assertArrayEquals(Util.arrayOf(0,Util.HEX_SIDES), arr.map(getOrientation));

    b.get(1,1).rotateClockwise();
    arr.rotateForward();

    assertArrayEquals(Point.get(1,1).getNeighbors().map(b.getAtUnsafe), arr);
    assertArrayEquals(Util.arrayOf(5,Util.HEX_SIDES), arr.map(getOrientation));

    b.get(1,1).rotateClockwise();
    arr.rotateForward();

    assertArrayEquals(Point.get(1,1).getNeighbors().map(b.getAtUnsafe), arr);
    assertArrayEquals(Util.arrayOf(4,Util.HEX_SIDES), arr.map(getOrientation));

    b.get(1,1).rotateCounterClockwise();
    arr.rotateBackward();

    assertArrayEquals(Point.get(1,1).getNeighbors().map(b.getAtUnsafe), arr);
    assertArrayEquals(Util.arrayOf(5,Util.HEX_SIDES), arr.map(getOrientation));

    //Check rotator on edge of board.

    b = new Board(2,2).fillWith(SimpleHex.create);
    b.set(0,0,new Rotator());

    var len = 2;
    arr = [b.getAt(Point.get(0,1)), b.getAt(Point.get(1,0))];
    assertArrayEquals(Util.arrayOf(0,len), arr.map(getOrientation));

    b.get(0,0).rotateClockwise();
    arr.rotateForward();

    assertArrayEquals(Point.get(0,0).getNeighbors().map(b.getAtSafe).filter(Util.isNonNull), arr);
    assertArrayEquals(Util.arrayOf(5,len), arr.map(getOrientation));

    b.get(0,0).rotateClockwise();
    arr.rotateForward();

    assertArrayEquals(Point.get(0,0).getNeighbors().map(b.getAtSafe).filter(Util.isNonNull), arr);
    assertArrayEquals(Util.arrayOf(4,len), arr.map(getOrientation));

    b.get(0,0).rotateCounterClockwise();
    arr.rotateBackward();

    assertArrayEquals(Point.get(0,0).getNeighbors().map(b.getAtSafe).filter(Util.isNonNull), arr);
    assertArrayEquals(Util.arrayOf(5,len), arr.map(getOrientation));
  }

}
