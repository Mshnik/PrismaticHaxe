package controller.util;

enum BoardAction {
  PLAY;
  EDIT;
  CREATE;
  DELETE;
  MOVE;
}

class BoardActionUtils {

  public static inline function toNiceString(action : BoardAction) : String {
    var str = Std.string(action);
    return str.charAt(0) + str.substring(1, str.length).toLowerCase();
  }

}
