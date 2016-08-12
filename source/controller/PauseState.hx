package controller;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSubState;

class PauseState extends FlxSubState {

  private var bg : FlxSprite;
  private var closeBtn : FlxButton;
  private var toLevelSelectBtn : FlxButton;

  public override function create() {
    super.create();

    bg = new FlxSprite().loadGraphic(AssetPaths.pause_bg__png);
    bg.updateHitbox();
    bg.x = (FlxG.width-bg.width)/2;
    bg.y = (FlxG.height-bg.height)/2;
    add(bg);

    closeBtn = new FlxButton(bg.x + 12, bg.y + 12, "", onCloseButtonClicked);
    closeBtn.loadGraphic(AssetPaths.pause_close_btn__png); //TODO - make this a three state graphic for normal/hover/press
    add(closeBtn);

    toLevelSelectBtn = new FlxButton(FlxG.width * 0.5, FlxG.height * 0.5 + 40, "Level Select", onLevelSelectButtonClicked);
    add(toLevelSelectBtn);
  }

  private function onCloseButtonClicked() {
    close();
  }

  private function onLevelSelectButtonClicked() {
    FlxG.switchState(new LevelSelectState());
  }

}
