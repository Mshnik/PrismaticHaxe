package model;

import common.HexType;
import common.Color;

class Rotator extends Hex {

  public function new() {
    super(HexType.ROTATOR);
  }

  /** Rotators don't output light - store lightIn and returns [] */
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    lightIn[correctForOrientation(side)] = c;
    updateHasLightInOut();
    return [];
  }

  /** Rotators are equal if they are equal as Hexes and both Rotators */
  public override function equals(h : Hex) : Bool {
    return super.equals(h) && h.isRotator();
  }

}
