package controller;

import haxe.ui.dialogs.files.FileDetails;
import haxe.ui.dialogs.files.FileDialogs;

class FilePicker {

  private static inline var PROJECT_PATH = "/Documents/PrismaticHaxe/";

  private var onComplete : String -> Void;
  public function new(onComplete : String -> Void) {
    this.onComplete = onComplete;
  }

  public inline function pickFile() {
    var p = PROJECT_PATH + LevelSelectState.DATA_PATH;
    FileDialogs.openFile({ dir: p, filter: "Prismatic Boards:*.xml" }, function(f : FileDetails){
      if (onComplete != null) {
        onComplete(f.name);
      }
    });
  }
}
