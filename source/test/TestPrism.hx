package test;
import common.Positionable.Tile;
import common.Util;
import game.Hex;
import common.Point;
import game.Color;
import game.Prism;
import game.Prism.ColorConnector;

class TestPrism extends TestCase {

  private static var COLORS;

  public override function setup() {
    super.setup();
    COLORS = Type.allEnums(Color);
  }

  public function testColorConnectors() {
    var c = new ColorConnector(null);
    assertEquals(Color.NONE, c.baseColor);

    for(color in COLORS) {
      assertFalse(c.canAcceptColor(color));
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
    assertFalse(c3.canAcceptColor(Color.GREEN));
    assertFalse(c3.canAcceptColor(Color.YELLOW));
    assertFalse(c3.canAcceptColor(Color.NONE));
  }

  public function testConstruction() {
    var p = new Prism();
    for(i in 0...Hex.SIDES) {
      assertEquals(Color.NONE, p.getLightIn(i));
      assertEquals(Color.NONE, p.getLightOut(i));
      for (i2 in 0...Hex.SIDES) {
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
    p.rotateCounterClockwise(); //all old indexes now +1
    assertEquals(Color.BLUE, p.getConnector(1,2).baseColor);
    assertEquals(Color.BLUE, p.getConnector(1,3).baseColor);
    assertEquals(Color.GREEN, p.getConnector(2,3).baseColor);
    assertFalse(p.getConnector(1,2).isLit());
    assertFalse(p.getConnector(1,3).isLit());
    assertFalse(p.getConnector(2,3).isLit());
    assertEquals(null, p.getConnector(0,1));
    assertEquals(null, p.getConnector(0,2));

    p.rotateClockwise();
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertEquals(Color.GREEN, p.getConnector(1,2).baseColor);
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());
    assertFalse(p.getConnector(1,2).isLit());

    p.rotateCounterClockwise();
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

    p.rotateClockwise();
    assertEquals(Color.YELLOW, p.getConnector(5,0).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,1).baseColor);
    assertEquals(Color.BLUE, p.getConnector(0,2).baseColor);
    assertEquals(Color.GREEN, p.getConnector(1,2).baseColor);
    assertFalse(p.getConnector(5,0).isLit());
    assertFalse(p.getConnector(0,1).isLit());
    assertFalse(p.getConnector(0,2).isLit());
    assertFalse(p.getConnector(1,2).isLit());
  }

  private inline function checkLight(p : Prism, expectedLightIn : Array<Color>,
                                     expectedLightOut : Array<Color>, expectedLit : Array<Array<Color>>) {
    assertArrayEquals(expectedLightIn, p.getLightInArray());
    assertArrayEquals(expectedLightOut, p.getLightOutArray());
    assertArrayEquals(expectedLit, Util.map(p.getLightingMatrix().asNestedArrays(),Tile.unWrap));
  }

  public function testLighting() {
    var p : Prism = new Prism().addConnector(0,1,Color.RED);

    var expectedLightIn : Array<Color> = Util.arrayOf(Color.NONE, Hex.SIDES);
    var expectedLightOut : Array<Color> = Util.arrayOf(Color.NONE, Hex.SIDES);

    var noneArray : Array<Color> = Util.arrayOf(Color.NONE, Hex.SIDES);
    var expectedLit : Array<Array<Color>> = [];
    for(i in 0...Hex.SIDES) {
      expectedLit.push(noneArray.copy());
    }

    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);

    //Add ineffectual light
    p.addLightIn(0, Color.BLUE);
    expectedLightIn[0] = Color.BLUE;
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);

    p.addLightIn(1, Color.RED);
    expectedLightIn[1] = Color.RED;
    checkLight(p, expectedLightIn, expectedLightOut, expectedLit);

    //Actually add light
  }

}
