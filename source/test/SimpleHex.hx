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
