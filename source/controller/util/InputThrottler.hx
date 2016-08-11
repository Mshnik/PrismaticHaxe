package controller.util;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.FlxG;

class InputThrottler {

  /** Throttling types - apply after first call. Sorted in order from slowest to fastest */
  public static var CONST : Int = 1;
  public static var SLOW_DECAY : Int = 2;
  public static var FAST_DECAY : Int = 3;
  public static var EVERY_FRAME : Int = 4;

  /** Amount of time input must occur (in sec) to start repeating */
  private static inline var START_REPEAT_TIME = 0.4;

  /** True if this is currently repeating the callback (key is held down) */
  private var currentlyRepeating : Bool;

  /** Amount of time (in ms) since the last call */
  private var timeSinceLastCall : Float;

  /** Min amount of time to the next call */
  private var timeToNextCall : Float;

  /** Throttling type for this. Should be one of the above constants. */
  private var throttleType : Int;

  /** Constructor for throttling on a key */
  public static inline function onKey(keyCode : Int, callback : Int -> Void, throttleType : Int) : InputThrottler {
    return new KeyThrottler(keyCode, callback, throttleType);
  }

  /** Constructor for throttling on a mouse in a rect */
  public static inline function onMouseInRect(rect : FlxRect, callback : Void -> Void, throttleType : Int) : InputThrottler {
    return new MouseInRectThrottler(rect, callback, throttleType);
  }

  public inline function new(throttleType : Int) {
    currentlyRepeating = false;
    timeSinceLastCall = 0;
    timeToNextCall = START_REPEAT_TIME;
    this.throttleType = throttleType;
    if (throttleType != CONST && throttleType != SLOW_DECAY
        && throttleType != FAST_DECAY && throttleType != EVERY_FRAME) {
      throw "Illegal throttle type " + throttleType + " - should be one of constants declared in InputThrottler";
    }
  }

  public function update(dt : Float) {
    timeSinceLastCall += dt;
    if (checkCondition()) {
      if (! currentlyRepeating) {
        timeSinceLastCall = 0;
        currentlyRepeating = true;
        callCallback();
      } else if (timeSinceLastCall >= timeToNextCall){
        timeSinceLastCall = 0;
        if (throttleType == CONST) {
          //nothing to do, leave timeToNextCall alone
        } else if (throttleType == EVERY_FRAME) {
          timeToNextCall = 0; //Repeat every frame at this point
        } else if (throttleType == SLOW_DECAY) {
          timeToNextCall = timeToNextCall * 0.9;
        } else if (throttleType == FAST_DECAY) {
          timeToNextCall = timeToNextCall/2;
        }
        callCallback();
      }
    } else {
      currentlyRepeating = false;
      timeToNextCall = START_REPEAT_TIME;
    }
  }

  private function checkCondition() : Bool {
    throw "Should be overridden in subclass " + this;
  }

  private function callCallback() {
    throw "Should be overriden in subclass " + this;
  }

  /** Can be overridden by subclasses. Those should call super() as well as their own logic */
  public function destroy() {
    currentlyRepeating = false;
    timeToNextCall = 0;
    timeSinceLastCall = 0;
  }
}

private class KeyThrottler extends InputThrottler {

  /** Callback for this KeyThrottler. Called repeatedly so long as key is pressed.
   * Arg is the key pressed (so multiple KeyThrottlers on different keys can share the same callback)
   **/
  private var callback : Int -> Void;

  /** The Key this is throttling */
  private var key : Int;
  private var keyAsArr : Array<Int>;

  public inline function new(key : Int, callback : Int -> Void, throttleType : Int) {
    super(throttleType);
    this.key = key;
    this.keyAsArr = [key];
    this.callback = callback;
  }

  private override inline function checkCondition() : Bool {
    return FlxG.keys.anyPressed(keyAsArr);
  }

  private override inline function callCallback() {
    callback(key);
  }

  public override function destroy() {
    super.destroy();
    callback = null;
    key = 0;
    keyAsArr = null;
  }
}

private class MouseInRectThrottler extends InputThrottler {
  /** Callback for this MouseInRectThrottler. Called repeatedly so long as mouse remains in rect.
   */
  private var callback : Void -> Void;

  /** The rect this is throttling on. Should be removed in destroy */
  private var rect : FlxRect;

  /** Point used for mouse's position. Should be removed in destroy */
  private var pt : FlxPoint;

  public inline function new (rect : FlxRect, callback : Void -> Void, throttleType : Int) {
    super(throttleType);
    this.rect = rect;
    this.callback = callback;
    pt = FlxPoint.get();
  }

  private override inline function checkCondition() : Bool {
    return rect.containsPoint(FlxG.mouse.getPosition(pt));
  }

  private override inline function callCallback() {
    callback();
  }

  public override function destroy() {
    super.destroy();
    callback = null;
    if (rect != null) {
      rect.put();
      rect = null;
    }
    if (pt != null) {
      pt.put();
      pt = null;
    }
  }
}
