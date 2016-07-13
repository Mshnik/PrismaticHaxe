package test;
import game.Hex;
class TestUtil extends TestCase  {

  public function testMod() {
    assertEquals(0, Util.mod(0,1));
    assertEquals(0, Util.mod(1,1));
    assertEquals(0, Util.mod(2,2));
    assertEquals(0, Util.mod(4,2));
    assertEquals(0, Util.mod(-1,1));
    assertEquals(0, Util.mod(-2,2));
    assertEquals(0, Util.mod(-4,2));

    assertEquals(1, Util.mod(1,2));
    assertEquals(1, Util.mod(-1,2));

    assertEquals(2, Util.mod(2,3));
    assertEquals(2, Util.mod(5,3));
    assertEquals(2, Util.mod(-1,3));
  }

  public function testEmptyArray() {
    for(i in 0...5) {
      var arr = Util.emptyArray(Hex, i);
      assertEquals(i, arr.length);
      for(x in arr) {
        assertEquals(null, x);
      }
    }
  }

  public function testArrayEquals() {
    assertTrue(Util.arrayEquals([1], [1]));
    assertTrue(Util.arrayEquals([1,2,3], [1,2,3]));
    assertTrue(Util.arrayEquals(["Hello", "Hi"], ["Hello", "Hi"]));
    assertFalse(Util.arrayEquals([], [1]));
    assertFalse(Util.arrayEquals([1], [2]));

    //Check multi-dimension support
    assertTrue(Util.arrayEquals([[1]], [[1]]));
    assertTrue(Util.arrayEquals([[1,2],[3,4]], [[1,2],[3,4]]));
  }

  public function testArrayRotation() {
    var arr = [1,2,3,4];
    assertArrayEquals([4,1,2,3], Util.rotateForward(arr));
    assertArrayEquals([3,4,1,2], Util.rotateForward(arr));
    assertArrayEquals([4,1,2,3], Util.rotateBackward(arr));
    assertArrayEquals([1,2,3,4], Util.rotateBackward(arr));
  }
}
