package test;
import common.Util;
import model.Hex;
class TestUtil extends TestCase {

  public function testEmptyArray() {
    for (i in 0...5) {
      var arr = Util.emptyArray(Hex, i);
      assertEquals(i, arr.length);
      for (x in arr) {
        assertEquals(null, x);
      }
    }
  }

  public function testFilledArray() {
    for (i in 0...5) {
      var arr = Util.arrayOf("Hello", i);
      assertEquals(i, arr.length);
      for (x in arr) {
        assertEquals("Hello", x);
      }
    }
  }

  public function testArrayEquals() {
    assertTrue(Util.arrayEquals([1], [1]));
    assertTrue(Util.arrayEquals([1, 2, 3], [1, 2, 3]));
    assertTrue(Util.arrayEquals(["Hello", "Hi"], ["Hello", "Hi"]));
    assertFalse(Util.arrayEquals([], [1]));
    assertFalse(Util.arrayEquals([1], [2]));

    //Check multi-dimension support
    assertTrue(Util.arrayEquals([[1]], [[1]]));
    assertTrue(Util.arrayEquals([[1, 2], [3, 4]], [[1, 2], [3, 4]]));
  }

  public function testMap2D() {
    var arr = [["Hello","Hi"],["Sup","Blah"]];
    var arr2 = [[5,2],[3,4]];
    assertArrayEquals(arr2, Util.map(arr, function(s : String){return s.length;}));
  }
}
