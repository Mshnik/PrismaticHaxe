package test;

import game.Hex;
class SimpleHex extends Hex {

  private static var nextID : Int = 0;

  public static function resetIDs() {
    nextID = 0;
  }

  public static function create() : Hex {
    return new SimpleHex();
  }

  public var rotations(default, null) : Int;
  public var id(default, null) : Int;

  public function new() {
    super();
    id = nextID++;
    rotations = 0;
  }

  override public function onRotate(oldOrientation : Int) {
    rotations++;
  }

  public override function toString() {
    return super.toString() + ", id=" + id;
  }
}
