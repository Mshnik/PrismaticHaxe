package model;

import common.*;

using common.IntExtender;
using common.CollectionExtender;

class Source extends Hex {

  private var availableColors(null, null) : Array<Color>;
  private var currentIndex(default, set) : Int;

  public function new() {
    super(HexType.SOURCE);
    availableColors = [Color.NONE];
    currentIndex = 0;
  }

  /** Helper to make sure light out is consistent with current active color */
  public inline function updateLightOut() {
    for(i in 0...Util.HEX_SIDES) {
      lightOut[i] = getCurrentColor();
    }
    updateHasLightInOut();
  }

  /** Make sure to set light out to correct current color, no matter what else */
  public override function resetLight() : Array<Int> {
    super.resetLight();
    if (availableColors != null) {
      updateLightOut();
    }
    return Util.toArray(0...Util.HEX_SIDES);
  }

  /** Adds the given color to the array of available colors, if it isn't already present.
   * If adding Color.NONE, does nothing.
   * If adding a duplicate, does nothing
   * Returns a reference to this for chaining
   **/
  public inline function addColor(c : Color) : Source {
    if (c == Color.NONE){
      return this;
    }
    var needsUpdate = false;
    if (availableColors[0] == Color.NONE){
      availableColors = [];
      needsUpdate = true;
    }
    if (availableColors.indexOf(c) == -1){
      availableColors[availableColors.length] = c;
    }
    if(needsUpdate) {
      updateLightOut();
    }
    return this;
  }

  /** Removes the given color from the array of available colors */
  public inline function removeColor(c : Color) : Source {
    if (c != Color.NONE) {
      var removed = availableColors.remove(c);
      if (availableColors.length == 0) {
        availableColors = [Color.NONE];
      }
      if (removed) {
        updateLightOut();
      }
    }
    return this;
  }

  /** Rotates to use the next available color */
  public inline function useNextColor() : Source {
    currentIndex++;
    return this;
  }

  /** Rotates to use the previous available color */
  public inline function usePreviousColor() : Source {
    currentIndex--;
    return this;
  }

  /** Returns the current color liting this spark */
  public inline function getCurrentColor() : Color {
    return availableColors[currentIndex];
  }

  public inline function getAvailableColors() : Array<Color> {
    return availableColors.copy();
  }

  public inline function set_currentIndex(i : Int) : Int {
      currentIndex = i.mod(availableColors.length);
      updateLightOut();
      return currentIndex;
  }

  /** For sparks, adding light in doesn't cause anything. Do keep track of it though */
  public override function addLightIn(side : Int, c : Color) : Array<Int> {
    var correctedSide = correctForOrientation(side);
    if(lightIn[correctedSide] == Color.NONE) {
      lightIn[correctedSide] = c;
    }
    updateHasLightInOut();

    return [];
  }

  /** Two Sources are equal if they are equal as Hexes and have equal arrays of available colors
   * This requires the same currently available color for both Sources.
   **/
  public override function equals(h : Hex) : Bool {
    return super.equals(h) && h.isSource() && currentIndex == h.asSource().currentIndex
      && availableColors.equals(h.asSource().getAvailableColors());
  }

}
