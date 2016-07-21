package model;

using common.IntExtender;

class Source extends Hex {

  private var availableColors(null, null) : Array<Color>;
  private var currentIndex(default, set) : Int;

  public function new() {
    super();
    availableColors = [Color.NONE];
    currentIndex = 0;
  }

  /** Helper to make sure light out is consistent with current active color */
  public function updateLightOut() {
    for(i in 0...Hex.SIDES) {
      lightOut[i] = getCurrentColor();
    }
  }

  /** Adds the given color to the array of available colors, if it isn't already present.
   * If adding Color.NONE, does nothing.
   * If adding a duplicate, does nothing
   * Returns a reference to this for chaining
   **/
  public function addColor(c : Color) : Source {
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

  /** Rotates to use the next available color */
  public function useNextColor() : Source {
    currentIndex++;
    return this;
  }

  /** Rotates to use the previous available color */
  public function usePreviousColor() : Source {
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

  public function set_currentIndex(i : Int) : Int {
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

    return [];
  }

}
