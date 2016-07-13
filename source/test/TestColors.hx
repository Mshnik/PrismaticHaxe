package test;

import game.Color;
import game.ColorUtil;
class TestColors extends haxe.unit.TestCase {

  public function testCompatability() {
    assertTrue(ColorUtil.areCompatable(Color.ANY, Color.ANY));
  }

}
