package controller.util;

class LevelUtils {
  private function new() {}

  /** Returns the name of the level in the given path (the last part of the path) */
  public static inline function getLevelName(levelPath : String) : String {
    return levelPath.substring(levelPath.lastIndexOf("/")+1,levelPath.indexOf("."));
  }
}
