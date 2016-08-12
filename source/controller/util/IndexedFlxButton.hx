package controller.util;
import flixel.ui.FlxButton;
class IndexedFlxButton extends FlxButton {

  private var index : Int;
  private var indexedOnClick : Int -> Void;

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Int->Void, index : Int = 0) {
    super(X, Y, Text, onClickHelper);
    this.index = index;
    this.indexedOnClick = OnClick;
  }

  private function onClickHelper() : Void {
    if (indexedOnClick != null) {
      indexedOnClick(index);
    }
  }
}
