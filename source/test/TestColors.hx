package test;

import common.Color;
import common.ColorUtil;
class TestColors extends TestCase {

  public function testCompatability() {
    var arr : Array<Color> = Type.allEnums(Color);
    for (c in arr) {
      assertFalse(ColorUtil.areCompatable(Color.NONE, c));
      assertFalse(ColorUtil.areCompatable(c, Color.NONE));
      assertFalse(ColorUtil.areCompatable(null, c));
      assertFalse(ColorUtil.areCompatable(c, null));
    }

    arr.remove(Color.NONE);
    for (c in arr) {
      assertTrue(ColorUtil.areCompatable(Color.ANY, c));
      assertTrue(ColorUtil.areCompatable(c, Color.ANY));
      assertTrue(ColorUtil.areCompatable(c, c));
    }
  }
}
