package test;
import model.Rotator;
import model.Source;
import model.Sink;
import model.Prism;
import common.Util;
import common.Point;
import common.Color;
import common.Positionable.Tile;
import model.Prism.ColorConnector;

using common.CollectionExtender;
using common.FunctionExtender;

class TestPrism extends TestCase {

  private static var COLORS : Array<Color>;

  public override function setup() {
    super.setup();
    COLORS = Type.allEnums(Color);
  }

  public function testColorConnectors() {
    var c = new ColorConnector(null);
    assertEquals(Color.NONE, c.baseColor);

    for(color in COLORS) {
      assertFalse(c.canAcceptColor(color));
      if (color != Color.NONE) {
        shouldFail(c.set_litColor.apply1B(color));
      }
    }

    assertEquals(Point.get(-1,-1), c.position);
    c.position = Point.get(1,2);
    assertEquals(Point.get(1,2), c.position);
    assertFalse(c.isDeadEnd());
    c.position = Point.get(3,3);
    assertEquals(Point.get(3,3), c.position);
    assertTrue(c.isDeadEnd());

    var c2 = new ColorConnector(Color.ANY);
    assertEquals(Color.ANY, c2.baseColor);

    for(color in COLORS) {
      if (color != Color.NONE) {
        assertTrue(c2.canAcceptColor(color));
      } else {
        assertFalse(c2.canAcceptColor(color));
      }
    }

    assertEquals(Color.NONE, c2.litColor);
    c2.litColor = Color.RED;
    assertEquals(Color.RED, c2.litColor);
    c2.litColor = Color.BLUE;
    assertEquals(Color.BLUE, c2.litColor);
    c2.unlight();
    assertEquals(Color.NONE, c2.litColor);


    var c3 = new ColorConnector(Color.RED);
    assertEquals(Color.RED, c3.baseColor);
    assertTrue(c3.canAcceptColor(Color.RED));
    assertTrue(c3.canAcceptColor(Color.ANY));
    assertFalse(c3.canAcceptColor(Color.BLUE));
    shouldFail(c3.set_litColor.apply1B(Color.BLUE));
    assertFalse(c3.canAcceptColor(Color.GREEN));
    shouldFail(c3.set_litColor.apply1B(Color.GREEN));
    assertFalse(c3.canAcceptColor(Color.YELLOW));
    shouldFail(c3.set_litColor.apply1B(Color.YELLOW));
    assertFalse(c3.canAcceptColor(Color.NONE));
  }

  public function testConstruction() {
    var p = new Prism();
    for(i in 0...Util.HEX_SIDES) {
      assertEquals(Color.NONE, p.getLightIn(i));
      assertEquals(Color.NONE, p.getLightOut(i));
      for (i2 in 0...Util.HEX_SIDES) {
        assertEquals(null, p.getConnector(i,i2));
      }
    }

    p.addConnector(0,1,Color.RED);
    assertEquals(Color.RED, p.getConnector(0,1).baseColor);
    assertFalse(p.getConnector(0,1).isLit());

    p.addConnector(0,1,Color.BLUE);
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertFalse(p.getConnector(0,1).isLit());

    p.addConnector(0,2,Color.BLUE);
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());


    p.addConnector(1,2,Color.GREEN);
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertEquals(Color.GREEN, p.getConnector(1,2).baseColor);
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());
    assertFalse(p.getConnector(1,2).isLit());

    //Let's start rotating!
    p.rotateClockwise(); //all old indexes now +1
    assertEquals(Color.BLUE, p.getConnector(1,2).baseColor);
    assertEquals(Color.BLUE, p.getConnector(1,3).baseColor);
    assertEquals(Color.GREEN, p.getConnector(2,3).baseColor);
    assertFalse(p.getConnector(1,2).isLit());
    assertFalse(p.getConnector(1,3).isLit());
    assertFalse(p.getConnector(2,3).isLit());
    assertEquals(null, p.getConnector(0,1));
    assertEquals(null, p.getConnector(0,2));

    p.rotateCounterClockwise();
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertEquals(Color.GREEN, p.getConnector(1,2).baseColor);
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());
    assertFalse(p.getConnector(1,2).isLit());

    p.rotateClockwise();
    assertEquals(Color.BLUE, p.getConnector(1,2).baseColor);
    assertEquals(Color.BLUE, p.getConnector(1,3).baseColor);
    assertEquals(Color.GREEN, p.getConnector(2,3).baseColor);
    assertFalse(p.getConnector(1,2).isLit());
    assertFalse(p.getConnector(1,3).isLit());
    assertFalse(p.getConnector(2,3).isLit());
    assertEquals(null, p.getConnector(0,1));
    assertEquals(null, p.getConnector(0,2));

    p.addConnector(0,1,Color.YELLOW);
    assertEquals(Color.YELLOW, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(1,2).baseColor);
    assertEquals(Color.BLUE, p.getConnector(1,3).baseColor);
    assertEquals(Color.GREEN, p.getConnector(2,3).baseColor);

    p.rotateCounterClockwise();
    assertEquals(Color.YELLOW, p.getConnector(5,0).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertEquals(Color.GREEN, p.getConnector(1,2).baseColor);
    assertFalse(p.getConnector(5,0).isLit());
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());
    assertFalse(p.getConnector(1,2).isLit());
  }

  /** Helper that checks if the lighting status of p matches the given arrays */
  private inline function checkLight(p : Prism, expectedLightIn : Array<Color>,
                                     expectedLightOut : Array<Color>, expectedLit : Array<Array<Color>>) {
    assertArrayEquals(expectedLightIn, p.getLightInArray());
    assertArrayEquals(expectedLightOut, p.getLightOutArray());
    assertArrayEquals(expectedLit, p.getLightingMatrix().asNestedArrays().map2D(Tile.unWrap));
    for(from in 0...Util.HEX_SIDES) {
      for(to in 0...Util.HEX_SIDES) {
        assertEquals(expectedLit[from][to] != Color.NONE, p.isConnectorLit(from,to));
      }
    }
  }

  /** Helper function that resets the lighting of p and checks that it is now completely unlit.
   * Resets the status of the arrays to be fully unlit.
   * Doesn't add or remove connections on the prism, however.
   **/
  private inline function resetAndCheck(p : Prism, expectedLightIn : Array<Color>,
                                        expectedLightOut : Array<Color>, expectedLit : Array<Array<Color>>) {
    p.acceptConnections = false;
    for(i in 0...Util.HEX_SIDES) {
      expectedLightIn[i] = Color.NONE;
      expectedLightOut[i] = Color.NONE;
      for(k in 0...Util.HEX_SIDES) {
        expectedLit[i][k] = Color.NONE;
      }
    }
    p.acceptConnections = true;
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
  }

  public function testLighting() {
    var p : Prism = new Prism().addConnector(0,1,Color.RED);

    var expectedLightIn : Array<Color> = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    var expectedLightOut : Array<Color> = Util.arrayOf(Color.NONE, Util.HEX_SIDES);

    var noneArray : Array<Color> = Util.arrayOf(Color.NONE, Util.HEX_SIDES);
    var expectedLit : Array<Array<Color>> = [];
    for(i in 0...Util.HEX_SIDES) {
      expectedLit.push(noneArray.copy());
    }

    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);

    //Add ineffectual light
    var arr = p.addLightIn(0, Color.BLUE);
    expectedLightIn[0] = Color.BLUE;
    assertArrayEquals([], arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    arr = p.addLightIn(1, Color.RED);
    expectedLightIn[1] = Color.RED;
    assertArrayEquals([], arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    //Actually add light
    arr = p.addLightIn(0,Color.RED);
    expectedLightIn[0] = Color.RED;
    expectedLightOut[1] = Color.RED;
    expectedLit[0][1] = Color.RED;
    assertArrayEquals([1], arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    //Check color branching
    p.addConnector(1,2,Color.RED);
    p.addConnector(0,2,Color.RED);
    arr = p.addLightIn(0, Color.RED);
    expectedLightIn[0] = Color.RED;
    expectedLightOut[1] = Color.RED;
    expectedLightOut[2] = Color.RED;
    expectedLit[0][1] = Color.RED;
    expectedLit[0][2] = Color.RED;
    assertArrayEquals([1,2],arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);

    //Check adding color doesn't do redundant addition
    arr = p.addLightIn(1, Color.RED);
    expectedLightIn[1] = Color.RED;
    expectedLit[1][2] = Color.RED;
    assertArrayEquals([], arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    //Check other colors of light don't work, but Color.ANY do
    p.addConnector(0,4, Color.BLUE);
    p.addConnector(0,5, Color.ANY);
    arr = p.addLightIn(0,Color.BLUE);
    expectedLightIn[0] = Color.BLUE;
    expectedLightOut[4] = Color.BLUE;
    expectedLightOut[5] = Color.BLUE;
    expectedLit[0][4] = Color.BLUE;
    expectedLit[0][5] = Color.BLUE;
    assertArrayEquals([4,5],arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    //Check dead ends
    p.addConnector(3,3,Color.RED);
    arr = p.addLightIn(3, Color.RED);
    expectedLightIn[3] = Color.RED;
    expectedLit[3][3] = Color.RED;
    assertArrayEquals([], arr);
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p, expectedLightIn, expectedLightOut, expectedLit);

    //Test rotation
    var p2 = new Prism().addConnector(0,1,Color.RED);
    p2.rotateClockwise();
    arr = p2.addLightIn(1, Color.RED);
    expectedLightIn[1] = Color.RED;
    expectedLightOut[2] = Color.RED;
    expectedLit[1][2] = Color.RED;
    assertArrayEquals([1], arr);
    checkLight(p2, expectedLightIn, expectedLightOut, expectedLit);
    resetAndCheck(p2, expectedLightIn, expectedLightOut, expectedLit);
  }

  public function testConnectionLocations() {
    var p = new Prism();
    assertArrayEquals([], p.getConnectionLocations());

    p.addConnector(0,1,Color.RED);
    assertEquals(Color.RED, p.getConnector(0,1).baseColor);
    assertArrayEquals([Point.get(0,1)], p.getConnectionLocations());

    p.rotateClockwise();
    assertEquals(Color.RED, p.getConnector(1,2).baseColor);
    assertArrayEquals([Point.get(1,2)], p.getConnectionLocations());

    p.rotateCounterClockwise();
    p.addConnector(0,2,Color.BLUE);
    assertArrayEquals([Point.get(0,1), Point.get(0,2)], p.getConnectionLocations());

    p.addConnector(0,2,Color.GREEN);
    assertArrayEquals([Point.get(0,1), Point.get(0,2)], p.getConnectionLocations());
  }

  public function testEquals() {
    assertEquitable(new Prism(), new Prism());
    assertNotEquitable(new Prism().asHex(), new Source().asHex());
    assertNotEquitable(new Prism().asHex(), new Sink().asHex());
    assertNotEquitable(new Prism().asHex(), new Rotator().asHex());

    var p = new Prism();
    var p2 = new Prism();

    p.addConnector(0,1,Color.RED);
    p2.addConnector(0,1,Color.RED);
    assertEquitable(p, p2);
    assertEquitable(p2, p);

    p.addConnector(1,2,Color.BLUE);
    assertNotEquitable(p, p2);
    assertNotEquitable(p2, p);

    p2.addConnector(1,2,Color.BLUE);
    assertEquitable(p, p2);
    assertEquitable(p2, p);

    p.rotateCounterClockwise();
    p2.rotateCounterClockwise();
    assertEquitable(p, p2);
    assertEquitable(p2, p);
  }
}
