package controller;

import flixel.FlxSprite;
import controller.util.LevelUtils;
import input.InputSettings;
import flixel.FlxG;
import controller.util.IndexedFlxButton;
import openfl.Assets;
import flixel.FlxState;

class LevelSelectState extends FlxState {

  private static var LEVEL_PATHS : Array<String>;
  private static var DATA_PATH : String;
  private static var LEVEL_EXTENSION : String;

  /** Call to set up level paths for all classic levels. Subsequent calls won't do anything */
  public static function initLevelPaths() {
    var levelListPath = AssetPaths.level_list__txt;
    DATA_PATH = levelListPath.substr(0, levelListPath.lastIndexOf("/")+1);
    LEVEL_EXTENSION = ".xml";
    LEVEL_PATHS = Assets.getText(levelListPath).split("\n").map(resolveLevelName);
  }

  /** Helper for initLevelPaths() */
  private static function resolveLevelName(name : String) : String {
    var p = DATA_PATH + name + LEVEL_EXTENSION;
    if (! Assets.exists(p, AssetType.TEXT)) {
      trace("Got non-existant level path " + p);
      #if debug
      throw "";
      #end
    }
    return p;
  }

  /** Buttons referring to levels by level index */
  private var levelButtons : Array<IndexedFlxButton>;

  override public function create() : Void {
    super.create();

    var bg = new FlxSprite();
    bg.loadGraphic(AssetPaths.main_bg__jpg);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    levelButtons = [];
    for(i in 0...LEVEL_PATHS.length) {
      var btn = new IndexedFlxButton(0,0,LevelUtils.getLevelName(LEVEL_PATHS[i]), onLevelButtonClicked, i);
      add(btn);
      levelButtons[i] = btn;
    }
  }

  /** Helper called when a level button is clicked */
  private function onLevelButtonClicked(index : Int) : Void {
    FlxG.switchState(new PlayState(LEVEL_PATHS[index], false));
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    if (InputSettings.CHECK_BACK()) {
      FlxG.switchState(new MainMenuState());
    }
  }

  public override function destroy() {
    super.destroy();
    levelButtons = null;
  }
}
