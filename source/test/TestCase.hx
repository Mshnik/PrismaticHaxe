package test;
import haxe.PosInfos;
class TestCase extends haxe.unit.TestCase {

  public function assertArrayEquals<T>( expected: Array<T> , actual: Array<T>,  ?c : PosInfos ) {
    currentTest.done = true;
    if (! Util.arrayEquals(expected, actual)){
      currentTest.success = false;
      currentTest.error   = "expected '" + expected + "' but was '" + actual + "'";
      currentTest.posInfos = c;
      throw currentTest;
    }
  }

}
