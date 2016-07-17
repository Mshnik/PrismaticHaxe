package game;

import common.Array2D;
class Board extends Array2D<Hex> {

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);
  }

  public inline function getBoard() : Array<Array<Hex>> {
    return asNestedArrays();
  }

}