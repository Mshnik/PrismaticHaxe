package controller;

import controller.util.ProjectPaths;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;

import controller.util.IndexedFlxButton;
import controller.util.LevelUtils;
import controller.util.ProjectPaths;
import controller.InputController;

class LevelSelectState extends FlxState {

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
    for(i in 0...ProjectPaths.LEVEL_PATHS.length) {
      var btn = new IndexedFlxButton(0,0,LevelUtils.getLevelName(ProjectPaths.LEVEL_PATHS[i]), onLevelButtonClicked, i);
      add(btn);
      levelButtons[i] = btn;
    }
  }

  /** Helper called when a level button is clicked */
  private function onLevelButtonClicked(index : Int) : Void {
    FlxG.switchState(PlayState.createClassic(ProjectPaths.LEVEL_PATHS[index]));
  }

  override public function update(elapsed : Float) : Void {
    super.update(elapsed);

    if (InputController.CHECK_BACK()) {
      FlxG.switchState(new MainMenuState());
    }
  }

  public override function destroy() {
    super.destroy();
    levelButtons = null;
  }
}
