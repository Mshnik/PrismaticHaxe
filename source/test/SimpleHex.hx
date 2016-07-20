package test;

import model.Color;
import model.Hex;

/** A simple hex extension, for testing.
 *  Functions as a prism that just reflects all light sent in back out.
**/
class SimpleHex extends Hex {

  public static function create() : Hex {
    return new SimpleHex();
  }

  public var rotations(default, null) : Int;

  public function new() {
    super();
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
}
