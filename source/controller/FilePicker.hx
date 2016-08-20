package controller;

import controller.util.ProjectPaths;
import haxe.ui.dialogs.files.FileDetails;
import haxe.ui.dialogs.files.FileDialogs;

class FilePicker {

  private static inline var FILTER = "Prismatic Boards:*.xml";

  private function new() {
    throw "Illegal Construction";
  }

  public static inline function pickFile(onComplete : String -> Void) {
    FileDialogs.openFile({ dir: ProjectPaths.LEVEL_FULL_PATH, filter: FILTER }, function(f : FileDetails){
      if (onComplete != null) {
        onComplete(f.name);
      }
    });
  }

  public static inline function saveFile(contents : String) {
    var details:FileDetails = new FileDetails();
    details.contents = contents;
    FileDialogs.saveFileAs( { dir: ProjectPaths.LEVEL_FULL_PATH, filter: FILTER }, details, function(f:FileDetails) {
      trace("Saved file: " + f.filePath);
    });
  }
}
