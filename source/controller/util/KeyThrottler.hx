package controller.util;
import flixel.FlxG;
class KeyThrottler {

  /** Key this is throttling on */
  private var key : Int;

  /** Copy of the key this is throttling on, as an array (to not have to construct it every update) */
  private var keyArr : Array<Int>;

  /** Callback for this KeyThrottler. Called repeatedly so long as key is pressed.
   * Arg is the key pressed (so multiple KeyThrottlers on different keys can share the same callback)
   **/
  private var callback : Int -> Void;

  /** Amount of time key is held down (in sec) to start repeating */
  private static inline var START_REPEAT_TIME = 0.4;

  /** True if this is currently repeating the callback (key is held down) */
  private var currentlyRepeating : Bool;

  /** Amount of time (in ms) since the last call */
  private var timeSinceLastCall : Float;

  /** Min amount of time to the next call */
  private var timeToNextCall : Float;

  public function new(key : Int, callback : Int -> Void) {
    this.key = key;
    keyArr = [key];
    this.callback = callback;
    currentlyRepeating = false;
    timeSinceLastCall = 0;
    timeToNextCall = START_REPEAT_TIME;
  }

  public function update(dt : Float) {
    timeSinceLastCall += dt;
    if (FlxG.keys.anyPressed(keyArr)) {
      if (! currentlyRepeating) {
        timeSinceLastCall = 0;
        currentlyRepeating = true;
        callback(key);
      } else if (timeSinceLastCall >= timeToNextCall){
        timeSinceLastCall = 0;
        timeToNextCall = 0; //Repeat every frame at this point
        callback(key);
      }
    } else {
      currentlyRepeating = false;
      timeToNextCall = START_REPEAT_TIME;
    }
  }
}
