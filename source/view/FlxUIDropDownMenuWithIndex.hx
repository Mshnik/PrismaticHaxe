package view;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.StrNameLabel;
import flixel.addons.ui.FlxUIDropDownMenu;

using common.IntExtender;

class FlxUIDropDownMenuWithIndex extends FlxUIDropDownMenu {

  public var selectedIndex(default, set) : Int;

  public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader, ?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void) {
    super(X, Y, DataList, Callback, Header, DropPanel, ButtonList, UIControlCallback);
    selectedIndex = 0;
  }

  private override function selectSomething(name:String, label:String) {
    trace("select Something called on " + name +", " + label);
    super.selectSomething(name, label);

    var ok = false;
    for (i in 0...list.length) {
      if (list[i].name == name) {
        selectedIndex = i;
        ok = true;
        break;
      }
    }
    if(! ok) throw "Index for " + name +", " + label + " in " + this + " not found";
  }

  private function set_selectedIndex(i : Int) : Int {
    trace("Setting index to " + i);
    var old = selectedIndex;
    selectedIndex = i.mod(list.length);
    if (selectedIndex != old) {
      onClickItem(selectedIndex);
    }
    return selectedIndex;
  }
}
