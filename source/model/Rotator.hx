package model;

import common.Equitable;
import common.Color;

class Rotator extends Hex implements Equitable<Rotator> {

  public function new() {
    super();
  }

  /** Rotators don't output light - store lightIn and returns [] */
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    lightIn[correctForOrientation(side)] = c;
    return [];
  }

  /** Rotators are equal if they are equal as Hexes and both Rotators */
  public override function equals(h : Hex) : Bool {
    return super.equals(h) && h.isRotator();
  }

}
