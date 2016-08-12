package controller;

import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class MainMenuState extends FlxState {

  /** Button moving to playing classic mode of the game */
  private var classicButton : FlxButton;

  public override function create() {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.scrollFactor.x=0;
    bg.scrollFactor.y=0;
    add(bg);

    classicButton = new FlxButton(0,0,"Classic", onClassicClick);
    classicButton.x = (FlxG.width-classicButton.width)/2;
    classicButton.y = 100;
    add(classicButton);
  }


  /** Function called when the 'classic' button is clicked */
  private function onClassicClick() {
    FlxG.switchState(new LevelSelectState());
  }

  public override function destroy() {
    super.destroy();

    classicButton = null;
  }
}
