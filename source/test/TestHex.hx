package test;

import game.Hex;

class SimpleHex extends Hex {

  public var rotations(default, null) : Int;

  public function new() {
    super();
    rotations = 0;
  }

  override public function onRotate() {
    rotations++;
  }

}

class TestHex extends haxe.unit.TestCase{

  public function testRotation() {
    var h : SimpleHex = new SimpleHex();
    assertEquals(0, h.orientation);
    assertEquals(0, h.rotations);
  }

}
