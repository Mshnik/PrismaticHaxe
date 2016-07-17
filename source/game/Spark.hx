package game;
import common.Util;

class Spark extends Hex {

  private var availableColors(default, set) : Array<Color>;
  private var currentIndex(default, set) : Int;

  public function new() {
    super();
    availableColors = [];
    currentIndex = 0;
  }

  /** Adds the given color to the array of available colors, if it isn't already present.
   * Returns a reference to this for chaining
   */
  public function addColor(c : Color) : Spark {
    ArrayHelper.addUnique(availableColors, c);
    return this;
  }

  /** Rotates to use the next available color */
  public function useNextColor() : Spark {
    currentIndex++;
    return this;
  }

  /** Rotates to use the previous available color */
  public function usePreviousColor() : Spark {
    currentIndex--;
    return this;
  }

  /** Returns the current color liting this spark */
  public function getCurrentColor() {
    return availableColors[currentIndex];
  }

  public function set_currentIndex(i : Int) : Int {
    if (availableColors.length > 0)
      return currentIndex = Util.mod(i, availableColors.length);
    else
      return currentIndex = i;
  }

  public function set_availableColors(arr : Array<Color>) : Array<Color> {
    return availableColors = arr;
  }
}
