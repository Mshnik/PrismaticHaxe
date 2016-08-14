package view;

import common.ColorUtil;
import common.Pair;
import common.Color;
import controller.util.GameType;

import flixel.addons.ui.FlxInputText;
import flixel.util.FlxGradient;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class HUDView extends FlxTypedGroup<FlxSprite>{

  /** Margin between top of screen and elements placed at the top of the hud */
  private static inline var TOP_MARGIN = 5;
  /** Height of the translucent top hud bar */
  private static inline var TOP_BAR_HEIGHT = 50;

  /** Font size of the text representing the score */
  private static inline var LEVEL_NAME_SIZE = 16;
  /** Font size of the text representing the score */
  private static inline var SCORE_TEXT_SIZE = 16;

  private var gameType : GameType;

  private var nameLabel : FlxText;
  private var scoreLabels : Map<Color, FlxText>;
  private var pauseButton : FlxButton;

  public function new(gameType : GameType) {
    super();

    this.gameType = gameType;

    var bg = FlxGradient.createGradientFlxSprite(FlxG.width, TOP_BAR_HEIGHT, [FlxColor.BLACK, FlxColor.TRANSPARENT]);
    add(bg);

    if (gameType == GameType.EDIT) {
      var nameLabel = new FlxInputText(TOP_MARGIN,TOP_MARGIN,0,"NEW LEVEL",LEVEL_NAME_SIZE);
      nameLabel.lines = 1;
      nameLabel.backgroundColor = FlxColor.TRANSPARENT;
      nameLabel.caretColor = FlxColor.WHITE;
      nameLabel.color = FlxColor.WHITE;
      this.nameLabel = nameLabel;
    } else {
      nameLabel = new FlxText(TOP_MARGIN,TOP_MARGIN,0,"NEW LEVEL",LEVEL_NAME_SIZE);
    }
    add(nameLabel);

    scoreLabels = [
      for(c in ColorUtil.realColors())
        c => new FlxText(0,TOP_MARGIN,0,"0/0", SCORE_TEXT_SIZE)
    ];

    withPauseHandler(null);

    var xInc = 3 * SCORE_TEXT_SIZE;
    var xPos = pauseButton.x - 4 * xInc;
    for(t in scoreLabels.iterator()) {
      t.x = xPos;
      xPos += xInc;
      add(t);
    }
  }

  /** Sets the level name. Adds a level name label if it doesn't yet exist. Returns this */
  public inline function withLevelName(levelName : String) : HUDView {
    nameLabel.text = levelName;
    return this;
  }

  /** Sets the pause handler. Returns this */
  public inline function withPauseHandler(func : Void -> Void) : HUDView {
    if (pauseButton != null) {
      remove(pauseButton);
    }
    pauseButton = new FlxButton(0,TOP_MARGIN/2,func);
    pauseButton.loadGraphic(AssetPaths.settings_icon__png);
    pauseButton.x = FlxG.width - pauseButton.width - TOP_MARGIN;
    add(pauseButton);
    return this;
  }

  /** Sets the level name changed handler (only for Edit mode). Returns this */
  public inline function withLevelNameChangedHandler(func : String -> String -> Void) : HUDView {
    if (gameType != GameType.EDIT){
      #if debug
      throw "Can't set level name changed in game mode " + gameType;
      #else
      return this;
      #end
    }

    var inputNameLabel : FlxInputText = cast(nameLabel, FlxInputText);
    inputNameLabel.callback = func;
    return this;
  }

  /** Returns the current level name */
  public inline function getLevelName() : String {
    return nameLabel.text;
  }

  /** Add overridden to make sure nothing in the HUD scrolls */
  public override function add(t : FlxSprite) : FlxSprite {
    if (t != null) {
      t.scrollFactor.x = 0;
      t.scrollFactor.y = 0;
    }
    return super.add(t);
  }

  /** Sets the goal labels to match the given map. Returns this */
  public inline function setGoalValues(map : Map<Color, Pair<Int, Int>>) : HUDView {
    for(c in map.keys()) {
      scoreLabels.get(c).text = map.get(c).getFirst() + "/" + map.get(c).getSecond();
      scoreLabels.get(c).color = ColorUtil.toFlxColor(c, map.get(c).getFirst() > 0);
    }
    return this;
  }
}
