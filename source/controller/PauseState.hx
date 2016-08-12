package controller;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSubState;

class PauseState extends FlxSubState {

  private var closeBtn : FlxButton;

  public override function create() {
    super.create();

    closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", onCloseButtonClicked);
    add(closeBtn);

  }

  private function onCloseButtonClicked() {
    close();
  }

}
