package game;
class Board {

  private var board : Array<Array<Hex>>;

  public function new() {
    board = new Array<Array<Hex>>();
  }

  /**
   * Ensures that the board is at least rows*cols large
   * Adds empty spots to bottom and right (i.e. 0,0 is considered top left)
   */
  public function ensureSize(rows : Int, cols : Int) : Void {
    for(arr in board) {
      while (arr.length < cols) {
        arr.push(null);
      }
    }
    while (board.length < rows) {
      board.push(Util.emptyArray(Hex, cols));
    }
  }
}
