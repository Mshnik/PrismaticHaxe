package view;
import common.Array2D;

class BoardView extends Array2D<HexSprite> {

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);
  }

}
