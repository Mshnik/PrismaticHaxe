package controller;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSubState;

class PauseState extends FlxSubState {

  private var closeBtn : FlxButton;
  private var toLevelSelectBtn : FlxButton;

  public override function create() {
    super.create();

    closeBtn = new FlxButton(FlxG.width * 0.5, FlxG.height * 0.5, "Close", onCloseButtonClicked);
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
