package test;
import common.Equitable;
import flixel.math.FlxPoint;
import model.Hex;
import common.Point;
import haxe.PosInfos;

using common.ArrayExtender;

class TestCase extends haxe.unit.TestCase {

  public override function setup() {
    Point.clearPool();
    Hex.resetIDs();
  }

  public override function tearDown() {
    Point.clearPool();
    Hex.resetIDs();
  }

  public inline function fail(?c : PosInfos) : Void {
    currentTest.success = false;
    currentTest.posInfos = c;
    throw currentTest;
  }

  public function assertEquitable<T : Equitable<T>>(expected : T, actual : T, ?c : PosInfos) : Void {
    currentTest.done = true;
    if (! EquitableUtils.equalsSafe(expected, actual)) {
      currentTest.error = "expected '" + expected + "' but got '" + actual + "'";
      fail(c);
    }
  }

  public function assertNotEquitable<T : Equitable<T>>(expected : T, actual : T, ?c : PosInfos) : Void {
    currentTest.done = true;
    if (EquitableUtils.equalsSafe(expected, actual)) {
      currentTest.error = "expected inequitable, but got " + expected + "' and '" + actual + "'";
      fail(c);
    }
  }

  public function assertNotEqual<T>(expected : T, actual : T, ?c : PosInfos) : Void {
    currentTest.done = true;
    if (actual == expected) {
      currentTest.error = "expected inequality but got '" + expected + "'";
      fail(c);
    }
  }

  public function assertArrayEquals<T>(expected : Array<T>, actual : Array<T>, ?c : PosInfos) {
    currentTest.done = true;
    if (!expected.equals(actual)) {
      currentTest.error = "expected '" + expected + "' but was '" + actual + "'";
      fail(c);
    }
  }

  public function assertFlxPointEquals(expected : FlxPoint, actual : FlxPoint, ?c : PosInfos) {
    currentTest.done = true;
    if (expected.x != actual.x || expected.y != actual.y) {
      currentTest.error = "expected '" + expected + "' but was '" + actual + "'";
      fail(c);
    }
  }

  public function shouldFail(func : Void -> Void, ?c : PosInfos) {
    currentTest.done = true;
    var errCaught = false;
    try{
      func();
    } catch(err : Dynamic) {
      errCaught = true;
    }

    if (! errCaught) {
      currentTest.error = "Exception not thrown";
      fail(c);
    }
  }
}
