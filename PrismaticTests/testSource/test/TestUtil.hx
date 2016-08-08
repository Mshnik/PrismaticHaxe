package test;
class TestUtil extends TestCase {

  public function testNullAndNonNullFuncs() {
    assertTrue(Util.isNull(null));
    assertFalse(Util.isNull("asdf"));
    assertFalse(Util.isNonNull(null));
    assertTrue(Util.isNonNull("asdf"));
  }

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

  public function testLinearInterpolate() {
    assertFlxPointEquals(FlxPoint.get(0,0), Util.linearInterpolate([], true));
    assertFlxPointEquals(FlxPoint.get(1,1), Util.linearInterpolate([FlxPoint.get(1,1)], true));
    assertFlxPointEquals(FlxPoint.get(1,1), Util.linearInterpolate([FlxPoint.get(2,2), FlxPoint.get(0,0)], true));

    assertFlxPointEquals(FlxPoint.get(0,0), Util.linearInterpolate([FlxPoint.get(1,1), FlxPoint.get(0,0), FlxPoint.get(-1,-1)], true));
  }
}
