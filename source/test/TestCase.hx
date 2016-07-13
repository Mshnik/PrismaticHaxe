package test;
import haxe.PosInfos;
class TestCase extends haxe.unit.TestCase {

  function assertNotEqual<T>( expected: T , actual: T,  ?c : PosInfos ) : Void 	{
    currentTest.done = true;
    if (actual == expected){
      currentTest.success = false;
      currentTest.error   = "expected inequality but got '" + expected + "'";
      currentTest.posInfos = c;
      throw currentTest;
    }
  }

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
