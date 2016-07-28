package model;

import common.Color;
import common.Point;
import haxe.xml.Fast;
import openfl.Assets;

class XMLParser {

  /** The file this XML Parser is responsible for reading. */
  private var content : Fast;

  /** The board under construction by this XML Parser */
  private var board : Board;

  public function new(file : Dynamic) {
      content = new Fast(Xml.parse(Assets.getText(file)).firstElement());
  }

  /** Parses a color from the given string */
  private inline static function parseColor(s : String) : Color {
    return Type.createEnum(Color, s);
  }

  /** Gets the row/col location for the given element.
   * Expects row and col attributes within the open tag.
   **/
  private inline static function getLocation(elm : Fast) : Point {
    return Point.get(Std.parseInt(elm.att.row), Std.parseInt(elm.att.col));
  }

  /** Returns the Board represented by this XMLParser.
   *  If this board has already been parsed, simply returns it.
   **/
  public function getBoard() : Board {
    if (board == null) {
      board = new Board();

      var width : Int = Std.parseInt(content.att.width);
      var height : Int = Std.parseInt(content.att.height);
      board.ensureSize(height, width);

      //Read Sinks
      for (sink in content.nodes.sink) {
        board.setAt(getLocation(sink), new Sink());
      }

      //Read Sources
      for (source in content.nodes.source) {
        var sourceModel = new Source();
        for (color in source.nodes.color) {
          sourceModel.addColor(parseColor(color.innerData));
        }
        board.setAt(getLocation(source), sourceModel);
      }

      //Read Prisms
      for(prism in content.nodes.prism) {
        var prismModel = new Prism();
        for (connector in prism.nodes.connector) {
          prismModel.addConnector(Std.parseInt(connector.att.from),
                                  Std.parseInt(connector.att.to),
                                  parseColor(connector.att.color));
        }
        board.setAt(getLocation(prism), prismModel);
      }

      //Read Rotators
      for(rotator in content.nodes.rotator) {
        board.setAt(getLocation(rotator), new Rotator());
      }
    }
    return board;
  }


}
