package view;
import common.Point;
import flixel.util.FlxColor;
import flixel.FlxSprite;
class PrismSprite extends HexSprite {

  private var connectorArr : Map<Point,ConnectorSprite>;
  private var sample = new ConnectorSprite(0,0,FlxColor.YELLOW);

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    connectorArr = new Map<Point,ConnectorSprite>();
  }

  public function addConnection(baseColor : FlxColor, from : Int, to : Int) : PrismSprite {
    connectorArr.set(Point.get(from,to),new ConnectorSprite(baseColor, from, to));
    return this;
  }


  public override function draw() : Void {
    super.draw();
    stamp(sample, Std.int(width/2), Std.int(height/2));
  }
}

class ConnectorSprite extends FlxSprite {

  private var connectionColor : FlxColor;
  private var sides : Point;
  public var isLit : Bool;

  public function new(c : FlxColor, s1 : Int, s2 : Int) {
    super();
    this.connectionColor = c;
    sides = Point.get(s1,s2);
    this.isLit = false;
  }


}
