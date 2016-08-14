package controller;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class MainMenuState extends FlxState {

  /** Button moving to playing classic mode of the game */
  private var classicButton : FlxButton;

  /** Button moving to playing edit (level design) mode of the game */
  private var editButton : FlxButton;

  public override function create() {
    super.create();

    var bg = new FlxSprite();
    bg.loadGraphic(AssetPaths.main_bg__jpg);
    add(bg);

    var title = new FlxSprite().loadGraphic(AssetPaths.Title__png);
    title.x = (FlxG.width-title.width)/2;
    title.y = 50;
    add(title);

    classicButton = new FlxButton(0,0,"Classic", onClassicClick);
    classicButton.x = (FlxG.width-classicButton.width)/2;
    classicButton.y = title.y + title.height + 50;
    add(classicButton);

    editButton = new FlxButton(0,0,"Edit", onEditClick);
    editButton.x = (FlxG.width-editButton.width)/2;
    editButton.y = classicButton.y + classicButton.height + 50;
    add(editButton);

    //SoundController.playClassicBackground();
  }


  /** Function called when the 'classic' button is clicked */
  private function onClassicClick() {
    FlxG.switchState(new LevelSelectState());
  }

  /** Function called when the 'edit' button is clicked */
  private function onEditClick() {
    FlxG.switchState(PlayState.createEdit());
  }

  public override function destroy() {
    super.destroy();

    classicButton = null;
  }
}
