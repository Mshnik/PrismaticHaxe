package view;

import openfl.events.KeyboardEvent;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxColor;

class FlxInputTextWithMinLength extends FlxInputText {

  private var minLength : Int;

  public function new(minLength : Int = 0, X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK, BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true) {
    super(X,Y,Width,Text,size,TextColor,BackgroundColor,EmbeddedFont);
    this.minLength = minLength;
  }

  public override function update(dt : Float) {
    super.update(dt);

    if (caretIndex < minLength+1) {
      caretIndex = minLength+1;
    }
  }

  private override function onKeyDown(e : KeyboardEvent) {
    if (hasFocus) {
      //8 == backspace, 46 == delete
      if ((e.keyCode == 8 || e.keyCode == 46) && text.length <= minLength) return;
      else super.onKeyDown(e);
    }
  }
}
