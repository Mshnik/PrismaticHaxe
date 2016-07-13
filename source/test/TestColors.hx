package test;

import game.Color;
import game.ColorUtil;
class TestColors extends TestCase {

  public function testCompatability() {
    var arr : Array<Color> = Type.allEnums(Color);
    for (c in arr) {
      assertFalse(ColorUtil.areCompatable(Color.NONE, c));
      assertFalse(ColorUtil.areCompatable(c, Color.NONE));
    }

    arr.remove(Color.NONE);
    for (c in arr) {
      assertTrue(ColorUtil.areCompatable(Color.ANY, c));
      assertTrue(ColorUtil.areCompatable(c, Color.ANY));
      assertTrue(ColorUtil.areCompatable(c, c));
    }
  }
}
