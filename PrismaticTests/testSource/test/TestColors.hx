package test;

import common.Color;
import common.ColorUtil;

using common.ArrayExtender;

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

  public function testColorArrays() {
    var arr : Array<Color> = Type.allEnums(Color);
    for(c in arr) {
      if (c == Color.NONE) {
        assertFalse(ColorUtil.realColors().contains(c));
        assertFalse(ColorUtil.realColorsAndAny().contains(c));
      } else if (c == Color.ANY) {
        assertFalse(ColorUtil.realColors().contains(c));
        assertTrue(ColorUtil.realColorsAndAny().contains(c));
      } else {
        assertTrue(ColorUtil.realColors().contains(c));
        assertTrue(ColorUtil.realColorsAndAny().contains(c));
      }
    }

    ColorUtil.realColors().remove(Color.BLUE);
    ColorUtil.realColorsAndAny().remove(Color.BLUE);

    //Make sure calling remove doesn't hurt getters
    for(c in arr) {
      if (c == Color.NONE) {
        assertFalse(ColorUtil.realColors().contains(c));
        assertFalse(ColorUtil.realColorsAndAny().contains(c));
      } else if (c == Color.ANY) {
        assertFalse(ColorUtil.realColors().contains(c));
        assertTrue(ColorUtil.realColorsAndAny().contains(c));
      } else {
        assertTrue(ColorUtil.realColors().contains(c));
        assertTrue(ColorUtil.realColorsAndAny().contains(c));
      }
    }
  }
}
