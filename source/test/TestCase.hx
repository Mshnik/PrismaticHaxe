package test;
import model.Hex;
import common.Point;
import common.Util;
import haxe.PosInfos;
class TestCase extends haxe.unit.TestCase {

  public override function setup() {
    Point.clearPool();
    Hex.resetIDs();
  }

  public override function tearDown() {
    Point.clearPool();
    Hex.resetIDs();
  }

  public function assertNotEqual<T>(expected : T, actual : T, ?c : PosInfos) : Void {
    currentTest.done = true;
    if (actual == expected) {
      currentTest.success = false;
      currentTest.error = "expected inequality but got '" + expected + "'";
      currentTest.posInfos = c;
      throw currentTest;
    }
  }

  public function assertArrayEquals<T>(expected : Array<T>, actual : Array<T>, ?c : PosInfos) {
    currentTest.done = true;
    if (!Util.arrayEquals(expected, actual)) {
      currentTest.success = false;
      currentTest.error = "expected '" + expected + "' but was '" + actual + "'";
      currentTest.posInfos = c;
      throw currentTest;
    }
  }

}
