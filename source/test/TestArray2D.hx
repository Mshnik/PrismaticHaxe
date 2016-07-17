package test;

import common.Positionable;
import common.Point;
import common.Array2D;

class TestArray2D extends TestCase {

  /** Helper that asserts that each hex's position is correct */
  private function checkTilePositions(b : Array2D<SimplePositionable>) {
    for(r in 0...b.getHeight()) {
      for(c in 0...b.getWidth()) {
        var h = b.get(r,c);
        if (h != null) {
          assertEquals(Point.get(r,c),h.position);
        }
      }
    }
  }

  public function testTiles() {
    var t : Tile<Int> = Tile.wrap(5);
    assertEquals(5, t.data);
    assertEquals(5, Tile.unWrap(t));
    assertEquals("Tile(5)", t.toString());
    assertEquals(Point.get(-1,-1), t.position);
    t.position = Point.get(1,2);
    assertEquals(Point.get(1,2), t.position);
  }

  public function testCreation() {
    var b = new Array2D<SimplePositionable>();
    assertEquals(0, b.getHeight());
    assertEquals(0, b.getWidth());
    assertArrayEquals([], b.asNestedArrays());

    var b = new Array2D<SimplePositionable>(3,3);
    assertEquals(3, b.getHeight());
    assertEquals(3, b.getWidth());
    assertArrayEquals([[null, null, null],[null, null, null],[null, null, null]], b.asNestedArrays());
  }

  public function testAddRowAndCol() {
    var b = new Array2D<SimplePositionable>();
    b.addRowTop();
    assertEquals(1, b.getHeight());
    assertEquals(0, b.getWidth());
    assertArrayEquals([[]], b.asNestedArrays());
    b.addColRight();
    assertEquals(1, b.getHeight());
    assertEquals(1, b.getWidth());
    assertTrue(b.isInBounds(Point.get(0,0)));
    assertFalse(b.isInBounds(Point.get(-1,0)));
    assertFalse(b.isInBounds(Point.get(0,-1)));
    assertFalse(b.isInBounds(Point.get(-1,-1)));
    assertFalse(b.isInBounds(Point.get(1,0)));
    assertFalse(b.isInBounds(Point.get(0,1)));
    assertFalse(b.isInBounds(Point.get(1,1)));
    assertArrayEquals([[null]], b.asNestedArrays());

    b.addRowTop();
    assertEquals(2, b.getHeight());
    assertEquals(1, b.getWidth());
    assertArrayEquals([[null], [null]], b.asNestedArrays());
    b.addColRight();
    assertEquals(2, b.getHeight());
    assertEquals(2, b.getWidth());
    assertArrayEquals([[null, null], [null, null]], b.asNestedArrays());

    var b2 = new Array2D<SimplePositionable>();
    b2.ensureSize(2, 2);
    assertTrue(b2.isInBounds(Point.get(0,0)));
    assertTrue(b2.isInBounds(Point.get(1,0)));
    assertTrue(b2.isInBounds(Point.get(0,1)));
    assertTrue(b2.isInBounds(Point.get(1,1)));
    assertFalse(b2.isInBounds(Point.get(2,1)));
    assertArrayEquals([[null, null], [null, null]], b2.asNestedArrays());
  }

  public function testSimplePositionableOnArray2D() {
    var b : Array2D<SimplePositionable> = new Array2D<SimplePositionable>();
    b.ensureSize(5, 5);

    var h : SimplePositionable = SimplePositionable.create();
    b.set(0, 0, h);
    checkTilePositions(b);
    assertEquals(h, b.get(0, 0));
    b.set(0, 0, null);
    assertEquals(null, b.get(0, 0));
    b.set(0, 0, h);
    b.remove(0, 0);
    assertEquals(null, b.get(0, 0));

    b.setAt(Point.get(0, 0), h);
    assertEquals(h, b.getAt(Point.get(0, 0)));
    b.removeAt(Point.get(0, 0));
    assertEquals(null, b.get(0, 0));
  }

  public function testSimplePositionableSwapping() {
    var h = SimplePositionable.create();
    var h2 = SimplePositionable.create();
    var h3 = SimplePositionable.create();

    var p = Point.get(0, 0);
    var p2 = Point.get(1, 0);
    var p3 = Point.get(1, 1);
    var p4 = Point.get(0, 1);

    var b = new Array2D<SimplePositionable>();
    b.ensureSize(2, 2);
    b.setAt(p, h);
    b.setAt(p2, h2);

    //At this point hexes 1 and 2 at their correct locations
    assertEquals(h, b.getAt(p));
    assertEquals(h2, b.getAt(p2));
    checkTilePositions(b);

    b.swap(p, p2);

    assertEquals(h, b.getAt(p2));
    assertEquals(h2, b.getAt(p));
    //checkSimplePositionablePositions(b);

    b.swap(p, p2);
    //checkSimplePositionablePositions(b);
    b.setAt(p3, h3);

    //At this point, all hexes at their correct locations

    var arr = [p, p2, p3, p4];
    b.swapManyForward(arr);

    assertArrayEquals([p, p2, p3, p4], arr);
    assertEquals(h, b.getAt(p2));
    assertEquals(h2, b.getAt(p3));
    assertEquals(h3, b.getAt(p4));
    assertEquals(null, b.getAt(p));
    //checkSimplePositionablePositions(b);

    b.swapManyBackward(arr);
    assertArrayEquals([p, p2, p3, p4], arr);
    assertEquals(h, b.getAt(p));
    assertEquals(h2, b.getAt(p2));
    assertEquals(h3, b.getAt(p3));
    assertEquals(null, b.getAt(p4));
    //checkSimplePositionablePositions(b);

    //At this point, all hexes at their correct locations
  }

  public function testShift() {
    var b : Array2D<SimplePositionable> = new Array2D<SimplePositionable>();
    b.ensureSize(3, 3);

    var h = b.set(0, 0, SimplePositionable.create());
    var h2 = b.set(0, 1, SimplePositionable.create());
    var h3 = b.set(1, 1, SimplePositionable.create());
    var h4 = b.set(1, 0, SimplePositionable.create());

    b.shift(1, 1);
    assertEquals(null, b.get(0, 0));
    assertEquals(null, b.get(0, 1));
    assertEquals(null, b.get(0, 2));
    assertEquals(null, b.get(1, 0));
    assertEquals(null, b.get(2, 0));
    assertEquals(h, b.get(1, 1));
    assertEquals(h2, b.get(1, 2));
    assertEquals(h3, b.get(2, 2));
    assertEquals(h4, b.get(2, 1));
    checkTilePositions(b);

    b.shift(-1, -1);
    assertEquals(h, b.get(0, 0));
    assertEquals(h2, b.get(0, 1));
    assertEquals(h3, b.get(1, 1));
    assertEquals(h4, b.get(1, 0));
    assertEquals(null, b.get(2, 0));
    assertEquals(null, b.get(2, 1));
    assertEquals(null, b.get(2, 2));
    assertEquals(null, b.get(1, 2));
    assertEquals(null, b.get(0, 2));
    checkTilePositions(b);

    //Test wrapping around
    b.shift(-1, -1);
    assertEquals(h, b.get(2, 2));
    assertEquals(h2, b.get(2, 0));
    assertEquals(h3, b.get(0, 0));
    assertEquals(h4, b.get(0, 2));
    assertEquals(null, b.get(1, 1));
    assertEquals(null, b.get(0, 1));
    assertEquals(null, b.get(1, 2));
    assertEquals(null, b.get(1, 0));
    assertEquals(null, b.get(2, 1));
    checkTilePositions(b);
  }

  public function testSize() {
    var b = new Array2D<SimplePositionable>().ensureSize(3,3);
    assertEquals(0, b.size);

    b.set(0,0,SimplePositionable.create());
    assertEquals(1, b.size);
    b.set(0,0,SimplePositionable.create());
    assertEquals(1, b.size);
    b.set(0,1,SimplePositionable.create());
    assertEquals(2,b.size);
    b.set(0,0,null);
    assertEquals(1,b.size);
    b.remove(0,1);
    assertEquals(0, b.size);
  }

  public function testIteration() {
    var b = new Array2D<SimplePositionable>();
    b.ensureSize(3,3);
    assertEquals(0, b.size);

    var h = b.set(0,0,SimplePositionable.create());
    assertEquals(1,b.size);
    var h2 = b.set(0,1,SimplePositionable.create());
    assertEquals(2,b.size);
    var h3 = b.set(1,0,SimplePositionable.create());
    assertEquals(3, b.size);
    var h4 = b.set(1,2,SimplePositionable.create());
    assertEquals(4, b.size);
    var h5 = b.set(2,1,SimplePositionable.create());
    assertEquals(5,b.size);
    checkTilePositions(b);

    var iter1 = b.iterator();
    var iter2 = [h,h2,h3,h4,h5].iterator();

    while(iter1.hasNext() && iter2.hasNext()) {
      assertEquals(iter2.next(), iter1.next());
    }
    assertFalse(iter1.hasNext());
    assertFalse(iter2.hasNext());

    var h6 = b.set(2,2,SimplePositionable.create());
    iter1 = b.iterator();
    iter2 = [h,h2,h3,h4,h5,h6].iterator();

    while(iter1.hasNext() && iter2.hasNext()) {
      assertEquals(iter2.next(), iter1.next());
    }
    assertFalse(iter1.hasNext());
    assertFalse(iter2.hasNext());

    //Make sure for loop comprehension works
    iter2 = [h,h2,h3,h4,h5,h6].iterator();
    for(hex in b) {
      assertEquals(iter2.next(), hex);
    }

    //Test removal
    var expectedSize = b.size;
    iter1 = b.iterator();
    while(iter1.hasNext()) {
      b.removeAt(iter1.next().position);
      expectedSize--;
      assertEquals(expectedSize, b.size);
    }
  }

  public function testFill() {
    var b = new Array2D<Tile<Int>>().ensureSize(5,5).fillWith(Tile.creator(5));
    var iter : Iterator<Tile<Int>> = b.iterator();
    while(iter.hasNext()) {
      assertEquals(5, iter.next().data);
    }
  }
}

class SimplePositionable extends Tile<Int>{

  public static function create() {
    return new SimplePositionable();
  }
}