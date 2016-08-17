package view;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;

class FlxUICheckBoxWithFullCallback extends FlxUICheckBox {

  public var fullCallback : String -> Bool -> Void;

  public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, ?LabelW:Int=100, ?Params:Array<Dynamic>, ?Callback:String -> Bool -> Void) {
    super(X, Y, Box, Check, Label, LabelW, Params, null);
    callback = callbackExt;
  }

  private inline function callbackExt() {
    if (fullCallback != null) {
      fullCallback(text, checked);
    }
  }

  public function toggle() {
    checked = !checked;
    if (callback != null) {
      callback();
    }
    if (broadcastToFlxUI) {
      FlxUI.event(FlxUICheckBox.CLICK_EVENT, this, checked, params);
    }
  }
}
