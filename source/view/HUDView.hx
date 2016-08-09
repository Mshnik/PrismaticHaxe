package view;
import common.ColorUtil;
import flixel.text.FlxText;
import common.Color;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class HUDView extends FlxTypedGroup<FlxSprite>{

  private var scoreLabels : Map<Color, FlxText>;

  public function new() {
    super();

    scoreLabels = [
      for(c in ColorUtil.realColors())
        c => new FlxText(0,0,0,"0/0")
    ];

    for(t in scoreLabels.iterator()) {
      add(t);
    }
  }

}
