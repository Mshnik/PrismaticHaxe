package test;

using common.ArrayExtender;

class TestArrayExtention extends TestCase {

  public function testContains() {
    assertTrue([1,2,3,4].contains(4));
    assertTrue([1,1,1].contains(1));
    assertFalse([1,2,3].contains(4));
  }

  public function testArrayEquals() {
    assertTrue([1].equals([1]));
    assertTrue([1, 2, 3].equals([1, 2, 3]));
    assertTrue(["Hello", "Hi"].equals(["Hello", "Hi"]));
    assertFalse([].equals([1]));
    assertFalse([1].equals([2]));

    //Check multi-dimension support
    assertTrue([[1]].equals([[1]]));
    assertTrue([[1, 2], [3, 4]].equals([[1, 2], [3, 4]]));
  }

  public function testFold() {
    assertEquals(10, [1,2,3,4].foldLeft(0,function(a,b){return a+b;}));
    assertEquals(6, ["A","BC","DEF"].foldLeft(0,function(a,b){return a.length + b;}));
  }

  public function removeDups() {
    assertArrayEquals([1,2,3], [1,1,1,1,2,2,2,3,3,3,1,2].removeDups());
  }

  public function testArrayRotation() {
    var arr = [1, 2, 3, 4];
    assertArrayEquals([4, 1, 2, 3], arr.rotateForward());
    assertArrayEquals([3, 4, 1, 2], arr.rotateForward());
    assertArrayEquals([4, 1, 2, 3], arr.rotateBackward());
    assertArrayEquals([1, 2, 3, 4], arr.rotateBackward());
  }

  public function testMap2D() {
    var arr = [["Hello","Hi"],["Sup","Blah"]];
    var arr2 = [[5,2],[3,4]];
    assertArrayEquals(arr2, arr.map2D(function(s : String){return s.length;}));
  }


}
