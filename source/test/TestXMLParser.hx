package test;

import common.Color;
import model.*;

class TestXMLParser extends TestCase {

  private function getTestBoard() : Board {
    return new XMLParser(AssetPaths.TEST__xml).getBoard();
  }

  public function testBoardAttributes() {
    var b = getTestBoard();
    assertEquals(4, b.getHeight());
    assertEquals(5, b.getWidth());
  }

  public function testSinks() {
    var b = getTestBoard();
    assertTrue(b.get(0,0).isSink());
    assertTrue(b.get(0,1).isSink());
  }

  public function testSources() {
    var b = getTestBoard();
    assertTrue(b.get(1,0).isSource());
    assertArrayEquals([Color.RED], b.get(1,0).asSource().getAvailableColors());
    assertTrue(b.get(1,1).isSource());
    assertArrayEquals([Color.RED, Color.BLUE], b.get(1,1).asSource().getAvailableColors());
  }

  public function testPrisms() {
    var b = getTestBoard();
    assertTrue(b.get(2,0).isPrism());

    assertTrue(b.get(2,1).isPrism());
    assertEquals(Color.BLUE, b.get(2,1).asPrism().getConnector(0,1).baseColor);
    assertEquals(Color.RED, b.get(2,1).asPrism().getConnector(1,2).baseColor);

    assertTrue(b.get(2,2).isPrism());
    assertEquals(Color.BLUE, b.get(2,2).asPrism().getConnector(0,1).baseColor);
    assertEquals(Color.RED, b.get(2,2).asPrism().getConnector(1,2).baseColor);
    assertEquals(Color.BLUE, b.get(2,2).asPrism().getConnector(1,0).baseColor);
  }

  public function testRotators() {
    var b = getTestBoard();
    assertTrue(b.get(3,1).isRotator());
  }
}
