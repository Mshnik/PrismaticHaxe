package model;

import model.Prism.ColorConnector;
import common.Color;
import common.Point;
import haxe.xml.Fast;
import openfl.Assets;

using model.XMLParser;
using common.IntExtender;
using common.ColorUtil;

class XMLParser {

  private function new (){}

  /** Attributes **/
  public static inline var WIDTH = "width";
  public static inline var HEIGHT = "height";
  public static inline var ROW = "row";
  public static inline var COL = "col";
  public static inline var ORIENTATION = "orientation";
  public static inline var CONNECTOR_FROM = "from";
  public static inline var CONNECTOR_TO = "to";
  public static inline var COLOR_ATTRIUBTE = "color";

  /** Elements */
  public static inline var BOARD = "board";
  public static inline var SINKS = "sink";
  public static inline var SOURCES = "source";
  public static inline var PRISMS = "prism";
  public static inline var ROTATORS = "rotator";
  public static inline var CONNECTORS = "connector";
  public static inline var COLOR_ELEMENTS = "color";

  /** Reading **/

  public inline static function read(path : Dynamic) : Board {
    var content = new Fast(Xml.parse(Assets.getText(path)).firstElement());
    var board = new Board();

    var width : Int = Std.parseInt(content.att.resolve(WIDTH));
    var height : Int = Std.parseInt(content.att.resolve(HEIGHT));
    board.ensureSize(height, width);

    //Read Sinks
    for (sink in content.nodes.resolve(SINKS)) {
      var sinkModel = new Sink();
      sinkModel.orientation = getOrientation(sink);
      board.setAt(getLocation(sink), sinkModel);
    }

    //Read Sources
    for (source in content.nodes.resolve(SOURCES)) {
      var sourceModel = new Source();
      for (color in source.nodes.resolve(COLOR_ELEMENTS)) {
        sourceModel.addColor(parseColor(color.innerData));
      }
      sourceModel.orientation = getOrientation(source);
      board.setAt(getLocation(source), sourceModel);
    }

    //Read Prisms
    for(prism in content.nodes.resolve(PRISMS)) {
      var prismModel = new Prism();
      for (connector in prism.nodes.resolve(CONNECTORS)) {
        prismModel.addConnector(Std.parseInt(connector.att.resolve(CONNECTOR_FROM)),
        Std.parseInt(connector.att.resolve(CONNECTOR_TO)),
        parseColor(connector.att.resolve(COLOR_ATTRIUBTE)));
      }
      prismModel.orientation = getOrientation(prism);
      board.setAt(getLocation(prism), prismModel);
    }

    //Read Rotators
    for(rotator in content.nodes.resolve(ROTATORS)) {
      var rotatorModel = new Rotator();
      rotatorModel.orientation;
      board.setAt(getLocation(rotator), rotatorModel);
    }

    return board;
  }

  /** Parses a color from the given string */
  private inline static function parseColor(s : String) : Color {
    return Type.createEnum(Color, s);
  }

  /** Gets the orientation for the given element. */
  private inline static function getOrientation(elm : Fast) : Int {
    return Std.parseInt(elm.att.resolve(ORIENTATION));
  }

  /** Gets the row/col location for the given element.
   * Expects row and col attributes within the open tag.
   **/
  private inline static function getLocation(elm : Fast) : Point {
    return Point.get(Std.parseInt(elm.att.resolve(ROW)), Std.parseInt(elm.att.resolve(COL)));
  }

  /** Writing **/

  public inline static function write(p : Dynamic, b : Board) : Void {
    #if flash
    throw "Can't perform file writing using flash.";
    #else

    b.disableOnRotate = true;

    var xml = Xml.createElement(BOARD);

    xml.set(HEIGHT, b.getHeight().toString());
    xml.set(WIDTH, b.getWidth().toString());

    for(r in 0...b.getHeight()) {
      for(c in 0...b.getWidth()) {
        if (b.get(r,c) != null) {
          var h : Hex = b.get(r,c);
          var orientation = h.orientation;
          h.orientation = 0;

          if (h.isPrism()) {
            xml.addPrismXML(h.asPrism(),r,c,orientation);
          } else if (h.isSource()) {
            xml.addSourceXML(h.asSource(),r,c,orientation);
          } else if (h.isSink()) {
            xml.addSinkXML(h.asSink(),r,c,orientation);
          } else if (h.isRotator()) {
            xml.addRotatorXML(h.asRotator(),r,c,orientation);
          } else {
            throw "Illegal Hex " + h;
          }

          h.orientation = orientation;
        }
      }
    }

    b.disableOnRotate = false;
    sys.io.File.saveContent(p,xml.toString());
    #end
  }

  #if !flash

  /** Helper that adds the color attribute.
   * Returns the data passed in with the newly added attribute.
   **/
  private static inline function addColorAttribute(data : Xml, c : Color) : Xml {
    data.set(COLOR_ATTRIUBTE, c.toString());
    return data;
  }

  /** Helper that adds the row and col attribute data.
   * Returns the data passed in with the newly added attributes.
   **/
  private static inline function addAttributes(data : Xml , r : Int, c : Int, o : Int) : Xml {
    data.set(ROW, r.toString());
    data.set(COL, c.toString());
    data.set(ORIENTATION, o.toString());
    return data;
  }

  /** Helper that creates an xml of the given color as an element */
  private static inline function createColorElementXML(c : Color) : Xml {
    var x = Xml.createElement(COLOR_ELEMENTS);
    x.addChild(Xml.createPCData(c.toString()));
    return x;
  }

  /** Helper that creates the Xml for a sink
   * Returns the data passed in with the newly added sink.
   **/
  public static inline function addSinkXML(data : Xml, sink : Sink, r : Int, c : Int, o : Int) : Xml {
    data.addChild(Xml.createElement(SINKS).addAttributes(r,c,o));
    return data;
  }

  /** Helper that creates the Xml for a rotator.
   * Returns the data passed in with the newly added rotator.
   **/
  public static inline function addRotatorXML(data : Xml, rotator : Rotator, r : Int, c : Int, o : Int) : Xml {
    data.addChild(Xml.createElement(ROTATORS).addAttributes(r,c,o));
    return data;
  }

  /** Helper that creates the Xml for a source.
   * Returns the data passed in with the newly added source.
   **/
  public static inline function addSourceXML(data : Xml, source : Source, r : Int, c : Int, o : Int) : Xml {
    var s : Xml = Xml.createElement(SOURCES).addAttributes(r,c,o);
    for(color in source.getAvailableColors()) {
      s.addChild(createColorElementXML(color));
    }
    data.addChild(s);
    return data;
  }

  /** Helper that creates the XML for a connector
   * Returns the data passed in with the newly added connector
   **/
  public static inline function addConnectorXML(data : Xml, from : Int, to : Int, color : Color) : Xml {
    var connector : Xml = Xml.createElement(CONNECTORS);
    connector.set(CONNECTOR_FROM, from.toString());
    connector.set(CONNECTOR_TO, to.toString());
    connector.set(COLOR_ATTRIUBTE, color.toString());
    data.addChild(connector);
    return data;
  }

  /** Helper that creates the Xml for a prism
   * Returns the data passed in with the newly added prism.
   **/
  public static inline function addPrismXML(data : Xml, prism : Prism, r : Int, c : Int, o : Int) : Xml {
    var p : Xml = Xml.createElement(PRISMS).addAttributes(r,c,o);

    for(pt in prism.getConnectionLocations()) {
      p.addConnectorXML(pt.row, pt.col, prism.getConnector(pt.row, pt.col).baseColor);
    }
    data.addChild(p);
    return data;
  }

  #end
}
