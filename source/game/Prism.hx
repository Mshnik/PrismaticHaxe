package game;
import common.Array2D;
class Prism extends Hex {

  private var connections : Array2D<Color>; //Connector from row to col
  private var lightIn : Array<Bool>;


  public function new() {
    super();

    connections = new Array2D<Color>().ensureSize(Hex.SIDES, Hex.SIDES);
  }


}
