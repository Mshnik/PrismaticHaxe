package controller.util;
import openfl.Assets;

class ProjectPaths {

  private function new() {
    throw "Illegal Init";
  }

  private static inline var PROJECT_PATH = "/Documents/PrismaticHaxe/";
  public static var LEVEL_PATHS(default, null) : Array<String>;
  public static var DATA_PATH(default, null) : String;
  public static var LEVEL_EXTENSION(default, null) : String;
  public static var LEVEL_FULL_PATH;

  /** Call to set up level paths for all classic levels. Subsequent calls won't do anything */
  public static function init() {
    var levelListPath = AssetPaths.level_list__txt;
    DATA_PATH = levelListPath.substr(0, levelListPath.lastIndexOf("/")+1);
    LEVEL_EXTENSION = ".xml";
    LEVEL_PATHS = Assets.getText(levelListPath).split("\n").map(resolveLevelName);
    LEVEL_FULL_PATH = PROJECT_PATH + DATA_PATH;
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

}
