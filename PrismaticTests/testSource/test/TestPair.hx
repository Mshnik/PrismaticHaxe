package test;

import common.Pair;
class TestPair extends TestCase {

  public function testConstruction() {
    var p : Pair<Int, String> = Pair.of(1,"Hello");

    assertEquals(1, p.getFirst());
    assertEquals("Hello", p.getSecond());
    assertEquals("(1,Hello)", p.toString());
  }

  public function testEquals() {
    var p : Pair<Int, String> = Pair.of(1,"Hello");
    assertEquitable(p, p);
    assertNotEquitable(p, null);

    var p2 : Pair<Int, String> = Pair.of(1,"Hello");

    assertEquitable(p, p2);

    var p3 : Pair<Int, String> = Pair.of(2,"Hello");
    assertNotEquitable(p, p3);

    var p4 : Pair<Int, String> = Pair.of(1, "Hi");
    assertNotEquitable(p, p4);
  }
}