package view;

import flixel.util.FlxColor;
import flixel.FlxG;
import common.ColorUtil;
import common.Pair;
import flixel.text.FlxText;
import common.Color;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class HUDView extends FlxTypedGroup<FlxSprite>{

  /** Margin between top of screen and elements placed at the top of the hud */
  private static inline var TOP_MARGIN = 5;
  /** Height of the translucent top hud bar */
  private static inline var TOP_BAR_HEIGHT = 35;

  /** Font size of the text representing the score */
  private static inline var SCORE_TEXT_SIZE = 16;

  private var scoreLabels : Map<Color, FlxText>;

  public function new() {
    super();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, TOP_BAR_HEIGHT, FlxColor.BLACK);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    scoreLabels = [
      for(c in ColorUtil.realColors())
        c => new FlxText(0,0,0,"0/0", SCORE_TEXT_SIZE)
    ];

    var xInc = 3 * SCORE_TEXT_SIZE;
    var xPos = FlxG.width - 4 * xInc;
    var yPos = TOP_MARGIN;
    for(t in scoreLabels.iterator()) {
      t.scrollFactor.x = 0;
      t.scrollFactor.y = 0;
      t.x = xPos;
      t.y = yPos;
      xPos += xInc;
      add(t);
    }
  }

  public function setGoalValues(map : Map<Color, Pair<Int, Int>>) : HUDView {
    for(c in map.keys()) {
      scoreLabels.get(c).text = map.get(c).getFirst() + "/" + map.get(c).getSecond();
      scoreLabels.get(c).color = ColorUtil.toFlxColor(c, map.get(c).getFirst() > 0);
    }
    return this;
  }

}
