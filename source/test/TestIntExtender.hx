package test;

using common.IntExtender;

class TestIntExtender extends TestCase{

  public function testMod() {

    assertEquals(0, (0).mod(1));
    assertEquals(0, (1).mod(1));
    assertEquals(0, (2).mod(2));
    assertEquals(0, (4).mod(2));
    assertEquals(0, (-1).mod(1));
    assertEquals(0, (-2).mod(2));
    assertEquals(0, (-4).mod(2));

    assertEquals(1, (1).mod(2));
    assertEquals(1, (-1).mod(2));

    assertEquals(2, (2).mod(3));
    assertEquals(2, (5).mod(3));
    assertEquals(2, (-1).mod(3));
  }

}
