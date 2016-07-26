package view;

import common.*;
import flixel.math.FlxPoint;

class HexSprite extends BaseSprite implements Positionable {

  //Magic number corresponds to graphic size
  public inline static var HEX_SIDE_LENGTH : Float = SCALE * 55.5;
  public inline static var SCALE : Float = 1.0;

  /** The position of this HexSprite in the BoardView. (-1,-1) when unset.
   * Mutated if this HexSprite is repositioned in the BoardView.
   **/
  public var position(default, set) : Point;

  /** Constructor for HexSprite
   *
   *  @param x - x position, graphically. 0 if unset
   *  @param y - y position, graphically. 0 if unset
   *
   **/
  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Fields
    angle = 0;
    position = Point.get(-1,-1);
    scale = FlxPoint.get(SCALE,SCALE);

    //Input handling
    enableMouseClicks(true, true);
    disableMouseDrag();
    disableMouseThrow();
    disableMouseSpring();
  }

  public inline function set_position(p : Point) : Point {
    return position = p;
  }

  public inline function isPrismSprite() : Bool {
    return Std.is(this, PrismSprite);
  }

//  public inline function isSink() : Bool {
//    return Std.is(this, Sink);
//  }
//
  public inline function isSourceSprite() : Bool {
    return Std.is(this, SourceSprite);
  }

  public inline function asPrismSprite() : PrismSprite {
    if(Std.is(this, PrismSprite)) return Std.instance(this, PrismSprite);
    throw this + " isn't PrismSprite";
  }

  public inline function asSourceSprite() : SourceSprite {
    if(Std.is(this, SourceSprite)) return Std.instance(this, SourceSprite);
    throw this + " isn't SourceSprite";
  }
//
//  public function asSink() : Sink {
//    if(Std.is(this, Sink)) return Std.instance(this, Sink);
//    throw this + " isn't SINK";
//  }
}
