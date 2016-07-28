package model;

import common.Color;
class Rotator extends Hex {

  public function new() {
    super();
  }

  /** Rotators don't output light - store lightIn and returns [] */
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    lightIn[correctForOrientation(side)] = c;
    return [];
  }

}
