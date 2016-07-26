package test;

using common.ArrayExtender;

class TestArrayExtention extends TestCase {

  public function testContains() {
    //TODO
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


}
