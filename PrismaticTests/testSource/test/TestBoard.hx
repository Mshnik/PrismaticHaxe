package test;

import common.ColorUtil;
import model.Score;
import model.Rotator;
import model.Hex;
import model.Prism;
import model.Sink;
import model.Source;
import model.Board;
import common.Util;
import common.Color;
import common.Point;
import util.SimpleHex;

using common.CollectionExtender;
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

  public function testConnectionGroups() {
    var b = new Board().ensureSize(3,3).fillWith(SimpleHex.create);

    for(h in b) {
      assertEquals(Board.DEFAULT_CONNECTION_GROUP, h.connectionGroup);
    }

    var nextGroup : Int = b.setAsNextConnectionGroup([Point.get(0,0)]);

    assertEquals(nextGroup, b.get(0,0).connectionGroup);
    assertEquals(Board.DEFAULT_CONNECTION_GROUP, b.get(0,1).connectionGroup);

    var nextGroup2 : Int = b.setAsNextConnectionGroup([Point.get(0,1), Point.get(1,0)]);
    assertEquals(nextGroup, b.get(0,0).connectionGroup);
    assertEquals(nextGroup2, b.get(0,1).connectionGroup);
    assertEquals(nextGroup2, b.get(1,0).connectionGroup);

    b.resetToDefaultConnectionGroup([Point.get(0,0)]);
    assertEquals(Board.DEFAULT_CONNECTION_GROUP, b.get(0,0).connectionGroup);
    assertEquals(nextGroup2, b.get(0,1).connectionGroup);
    assertEquals(nextGroup2, b.get(1,0).connectionGroup);
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

  public function testLightingWithConnectionGroup() {
    var b = new Board().ensureSize(3,3);

    b.set(0,0,new Source().addColor(Color.BLUE));
    assertEquals(Board.DEFAULT_CONNECTION_GROUP, b.get(0,0).connectionGroup);
    b.set(0,1,new Prism().addConnector(5,0,Color.BLUE));
    assertEquals(Board.DEFAULT_CONNECTION_GROUP, b.get(0,1).connectionGroup);

    b.relight();

    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));

    b.setAsNextConnectionGroup([Point.get(0,1)]);
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.relight();
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.resetToDefaultConnectionGroup([Point.get(0,1)]);
    assertEquals(Color.NONE, b.get(0,1).getLightIn(5));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(0));

    b.relight();
    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));

    b.get(0,1).asPrism().addConnector(4,2,Color.BLUE);
    b.set(1,0,new Source().addColor(Color.BLUE));
    b.setAsNextConnectionGroup([Point.get(1,0)]);

    b.relight();
    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));
    assertEquals(Color.NONE, b.get(0,1).getLightIn(4));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(2));

    b.get(0,1).asPrism().addConnector(3,2,Color.BLUE);
    b.set(1,1, new Prism().addConnector(5,0,Color.BLUE));

    b.resetToDefaultConnectionGroup([Point.get(1,0)]);
    var group = b.setAsNextConnectionGroup([Point.get(1,0), Point.get(1,1)]);

    assertEquals(group, b.get(1,0).connectionGroup);
    assertEquals(group, b.get(1,1).connectionGroup);

    b.relight();
    assertEquals(Color.BLUE, b.get(0,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(0,1).getLightOut(0));
    assertEquals(Color.NONE, b.get(0,1).getLightIn(4));
    assertEquals(Color.NONE, b.get(0,1).getLightOut(2));
    assertEquals(Color.NONE, b.get(0,1).getLightIn(3));

    assertEquals(Color.BLUE, b.get(1,1).getLightIn(5));
    assertEquals(Color.BLUE, b.get(1,1).getLightOut(0));
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

    b.set(1,1,r);

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

  public function testDisableOnRotate() {
    var b = new Board(3,3);
    assertFalse(b.disableOnRotate);

    b.disableOnRotate = true;
    assertTrue(b.disableOnRotate);

    var source = b.set(0,1,new Source());
    b.set(1,1,new Rotator()).rotateClockwise();

    assertEquals(source, b.get(0,1));

    b.disableOnRotate = false;
    b.get(1,1).rotateClockwise();
    assertEquals(source, b.get(1,2));

    b.get(1,1).rotateCounterClockwise();
    assertEquals(source, b.get(0,1));
  }

  public function testEquals() {
    var b = new Board(3,3).fillWith(SimpleHex.create);
    assertEquitable(b, b);
    assertNotEquitable(b, null);
    assertNotEquitable(null, b);

    var b2 = new Board(3,3).fillWith(SimpleHex.create);
    assertEquitable(b, b2);

    b.set(0,0, new Source());

    assertNotEquitable(b2, b);

    b2.set(0,0,new Source());
    assertEquitable(b, b2);

    b.getScore().setGoal(Color.RED, 1);
    assertNotEquitable(b2, b);

    b2.getScore().setGoal(Color.RED, 1);
    assertEquitable(b, b2);
  }

  public function testScores() {
    var b = new Board(3,3);

    var s = b.getScore();
    for(c in ColorUtil.realColors()) {
      assertEquals(0, s.getGoal(c));
    }

    assertEquals(s, b.relight());
    for(c in ColorUtil.realColors()) {
      assertEquals(0, s.getGoal(c));
    }

    s.setGoal(Color.RED, 2);
    assertFalse(s.isSatisfied());

    b.set(0,0,new Source().addColor(Color.RED));
    b.set(0,1,new Sink());
    b.set(1,0,new Sink());

    b.relight();
    assertEquals(2, s.getCount(Color.RED));
    assertTrue(s.isSatisfied());

    b.get(0,0).asSource().addColor(Color.BLUE).useNextColor();
    b.relight();
    assertEquals(0, s.getCount(Color.RED));
    assertEquals(2, s.getCount(Color.BLUE));
    assertFalse(s.isSatisfied());

    b.get(0,0).asSource().usePreviousColor();
    b.relight();
    assertEquals(0, s.getCount(Color.BLUE));
    assertEquals(2, s.getCount(Color.RED));
    assertTrue(s.isSatisfied());

    b.set(2,2,new Source().addColor(Color.GREEN));
    b.set(2,1,new Sink());

    s.setGoal(Color.GREEN, 1);
    b.relight();
    assertEquals(0, s.getCount(Color.BLUE));
    assertEquals(1, s.getCount(Color.GREEN));
    assertEquals(2, s.getCount(Color.RED));
    assertTrue(s.isSatisfied());

    var s2 = b.relight();
    assertEquals(0, s2.getCount(Color.BLUE));
    assertEquals(1, s2.getCount(Color.GREEN));
    assertEquals(2, s2.getCount(Color.RED));
    assertTrue(s2.isSatisfied());
  }
}
