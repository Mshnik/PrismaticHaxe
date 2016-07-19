package test;

import game.Color;
import game.Hex;

/** A simple hex extension, for testing.
 *  Functions as a prism that just reflects all light sent in back out.
**/
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
    rotationListener = function(h : Hex, i : Int) {
      var sH : SimpleHex = cast(h, SimpleHex);
      sH.rotations++;
    };
  }

  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    lightIn[correctForOrientation(side)] = c;
    lightOut[correctForOrientation(side)] = c;
    return [correctForOrientation(side)];
  }

  public override function toString() {
    return super.toString() + ", id=" + id;
  }
}
