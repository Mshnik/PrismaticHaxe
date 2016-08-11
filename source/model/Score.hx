package model;

import common.Pair;
import common.ColorUtil;
import common.Color;

using common.CollectionExtender;

class Score {

  private var scoreByColor : Map<Color, ScorePair>;

  public function new() {
    scoreByColor = [
      for(c in ColorUtil.realColors()) {
        c => new ScorePair();
      }
    ];
  }

  /** Two goals are equal if they have the same color requirements.
   * They don't have to have the same current values.
   **/
  public function equals(s : Score) : Bool {
    if (this == s) return true;
    if (s == null) return false;
    for(c in ColorUtil.realColors()) {
      if (getGoal(c) != s.getGoal(c)) return false;
    }
    return true;
  }

  /** Returns the goal for the given color */
  public inline function getGoal(c : Color) : Int {
    return scoreByColor.get(c).getGoal();
  }

  /** Returns the current count for the given color */
  public inline function getCount(c : Color) : Int {
    return scoreByColor.get(c).getCurrent();
  }

  /** Returns a full map of the color to the current and goal for that color */
  public inline function get() : Map<Color, Pair<Int, Int>> {
    return [
      for(c in ColorUtil.realColors()) c => Pair.of(getCount(c), getGoal(c))
    ];
  }

  /** Checks if this Score is currently satisfied. Returns true if each color requirement is satisfied */
  public function isSatisfied() : Bool {
    for(c in ColorUtil.realColors()) {
      if (! scoreByColor.get(c).isSatisfied()) return false;
    }
    return true;
  }

  /** Sets the requirement for the given color to the given goal. Returns this */
  public inline function setGoal(c : Color, goal : Int) : Score {
    scoreByColor.get(c).setGoal(goal);
    return this;
  }

  /** Sets the requirement for the given colors to the given goals. Returns this */
  public inline function setGoals(colors : Array<Color>, goals : Array<Int>) : Score {
    if (colors.length != goals.length) throw "Arrays " + colors + " and " + goals + " don't match length";
    for (i in 0...colors.length) {
      setGoal(colors[i], goals[i]);
    }
    return this;
  }

  /** Sets the current count for the given color to the given count. Returns this */
  public inline function setCount(c : Color, count : Int) : Score {
    scoreByColor.get(c).setCurrent(count);
    return this;
  }

  /** Adds 1 to the current count for the given color. Returns this. */
  public inline function increment(c : Color) : Score {
    scoreByColor.get(c).setCurrent(scoreByColor.get(c).getCurrent() + 1);
    return this;
  }

  /** Sets the current count for the given colors to the given counts. Returns this */
  public inline function setCounts(colors : Array<Color>, counts : Array<Int>) : Score {
    if (colors.length != counts.length) throw "Arrays " + colors + " and " + counts + " don't match length";
    for (i in 0...colors.length) {
      setCount(colors[i], counts[i]);
    }
    return this;
  }

  /** Resets the current counts for all colors to 0. Returns this */
  public inline function reset() : Score {
    for (c in ColorUtil.realColors()) {
      scoreByColor.get(c).setCurrent(0);
    }
    return this;
  }

  /** Returns a string representation of this score */
  public function toString() : String {
    return scoreByColor.toString();
  }
}

/** A simple mutable int pair implementation for score. Represents a current count and a goal count */
private class ScorePair extends Pair<Int, Int> {
  public function new() {
    super(0,0);
  }

  public inline function getCurrent() : Int {
    return _1;
  }

  public inline function getGoal() : Int {
    return _2;
  }

  public inline function setCurrent(c : Int) : Int {
    return _1 = c;
  }

  public inline function setGoal(g : Int) : Int {
    return _2 = g;
  }

  public inline function isSatisfied() : Bool {
    return _1 >= _2;
  }

  public override function toString() : String {
    return _1 + "/" + _2;
  }
}
