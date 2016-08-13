package controller;
import flixel.FlxG;
class SoundController {

  private static var BACKGROUND_VOLUME = 0.5;

  private static var CLASSIC_BACKGROUND_MUSIC : Dynamic = AssetPaths.menu_background__mp3;
  private static var classicBackgroundPlaying : Bool;

  private function new() {}

  public static function init() {
    classicBackgroundPlaying = false;
  }

  public static inline function playClassicBackground() {
    if (! classicBackgroundPlaying) {
      FlxG.sound.playMusic(AssetPaths.menu_background__mp3, BACKGROUND_VOLUME, true);
      classicBackgroundPlaying = true;
    }
  }
}
