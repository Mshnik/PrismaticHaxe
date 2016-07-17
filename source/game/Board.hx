package game;

import common.Array2D;
class Board extends Array2D<Hex> {

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);
  }

  public inline function getBoard() : Array<Array<Hex>> {
    return asNestedArrays();
  }

  /** Overridden to narrow return type */
  public inline override function ensureSize(rows : Int, cols : Int) : Board {
    super.ensureSize(rows, cols);
    return this;
  }

  /** Overridden to narrow return type */
  public inline override function fillWith(elmCreator : Void->Hex) : Board {
    super.fillWith(elmCreator);
    return this;
  }

}