package test;
import game.Hex;
class TestUtil extends haxe.unit.TestCase  {

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
}
