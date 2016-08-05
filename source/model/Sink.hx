package model;

import common.Equitable;
import common.Color;

class Sink extends Hex {

  private var currentColor : Color;

  public function new() {
    super();
    currentColor = Color.NONE;
  }

  public inline function getCurrentColor() : Color {
    return currentColor;
  }

  public override function resetLight() : Array<Int> {
    currentColor = Color.NONE;
    return super.resetLight();
  }

  /** For sinks, adding light in sets the current color if it's the first light in.
   * Never sends light back out though.
   **/
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    var correctedSide = correctForOrientation(side);
    if(lightIn[correctedSide] == Color.NONE) {
      lightIn[correctedSide] = c;
    }
    if (currentColor == Color.NONE) {
      currentColor = c;
    }

    return [];
  }

  /** Two sinks are equal if they are equal as Hexes and both sinks. */
  public override function equals(h : Hex) : Bool {
    return super.equals(h) && h.isSink();
  }
}
