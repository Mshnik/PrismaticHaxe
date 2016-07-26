package model;

import common.*;

using common.IntExtender;

class Board extends Array2D<Hex> {

  private var sources : Array<Source>;
  private var sinks : Array<Sink>;

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);
    sources = [];
    sinks = [];
  }

  /** Helper to add a source to the sources array.
   * If safe, removes first to avoid duplication
   **/
  private function addSource(s : Source, safe : Bool = false) : Board {
    if (safe) {
      sources.remove(s);
    }
    sources.push(s);
    return this;
  }

  /** Helper to add a sink to the sinks array.
   * If safe, removes first to avoid duplication
   **/
  private function addSink(s : Sink, safe : Bool = false) : Board {
    if (safe) {
      sinks.remove(s);
    }
    sinks.push(s);
    return this;
  }

  public function getSources() : Array<Source> {
    return sources.copy();
  }

  public function getSinks() : Array<Sink> {
    return sinks.copy();
  }

  public inline function getBoard() : Array<Array<Hex>> {
    return asNestedArrays();
  }

  /** Overridden to narrow return type */
  public override function ensureSize(rows : Int, cols : Int) : Board {
    super.ensureSize(rows, cols);
    return this;
  }

  /** Overridden to narrow return type */
  public override function addRowTop() : Board {
    super.addRowTop();
    return this;
  }

  /** Overridden to narrow return type */
  public override function addRowBottom() : Board {
    super.addRowBottom();
    return this;
  }

  /** Overridden to narrow return type */
  public override function addColLeft() : Board {
    super.addColLeft();
    return this;
  }

  /** Overridden to narrow return type */
  public override function addColRight() : Board {
    super.addColRight();
    return this;
  }

  /** Returns the T at the given row,col. If safe, returns null if OOB */
  public override function get(row : Int, col : Int, safe : Bool = false) : Hex {
    return super.get(row, col, safe);
  }

  /** Returns the T at the given point */
  public override function getAt(p : Point, safe : Bool = false) : Hex {
    return super.getAt(p, safe);
  }

  /** In addition to calling super.set, updates sources/sinks as necessary */
  public override function set(row : Int, col : Int, h : Hex) : Hex {
    var oldH : Hex = get(row, col);
    super.set(row, col, h);

    if (oldH != h) {
      if (Std.is(oldH, Source)) {
        sources.remove(Std.instance(oldH,Source));
      } else if (Std.is(oldH, Sink)) {
        sinks.remove(Std.instance(oldH,Sink));
      }
      if (Std.is(h, Source)) {
        addSource(Std.instance(h,Source));
      } else if (Std.is(h, Sink)) {
        addSink(Std.instance(h,Sink));
      }
    }
    return h;
  }

  /** In addition to calling super.swap, updates sources/sinks as necessary */
  public override function swap(p1 : Point, p2 : Point) : Board {
    super.swap(p1, p2);

    var h1 = getAt(p1);
    var h2 = getAt(p2);

    if (Std.is(h1, Source)) {
      addSource(Std.instance(h1,Source), true);
    } else if (Std.is(h1, Sink)) {
      addSink(Std.instance(h1,Sink), true);
    }

    if (Std.is(h2, Source)) {
      addSource(Std.instance(h2,Source), true);
    } else if (Std.is(h2, Sink)) {
      addSink(Std.instance(h2,Sink), true);
    }

    return this;
  }

  /** Overridden to narrow return type */
  public override function swapManyForward(locations : Array<Point>) : Board {
    super.swapManyForward(locations);
    return this;
  }

  /** Overridden to narrow return type */
  public override function swapManyBackward(locations : Array<Point>) : Board {
    super.swapManyBackward(locations);
    return this;
  }

  /** Overridden to narrow return type */
  public override function fillWith(elmCreator : Void->Hex) : Board {
    super.fillWith(elmCreator);
    return this;
  }

  /** Causes the board to relight entirely. */
  public function relight() {

    //First, remove light from the whole board.
    for(h in this) {
      h.resetLight();
    }

    var queue : Array<LightPusher> = [];
    //Setup - all sources push their color of light out in all directions
    for(s in sources) {
      s.updateLightOut();
      for(i in 0...Util.HEX_SIDES) {
        queue.push(LightPusher.get(s.position, s.getCurrentColor(), i));
      }
    }

    //Iteration - pop light pusher, push light in, add pushers for any continuing light
    while (queue.length > 0) {
      var l = queue.shift();
      var h : Hex = getAt(l.destination, true);
      if (h != null && h.acceptConnections) {
        var newOut = h.addLightIn(l.inDirection,l.color);
        for (x in newOut) {
          if (h.getLightOut(x) != Color.NONE) {
            queue.push(LightPusher.get(h.position,h.getLightOut(x),x));
          }
        }
      }
    }
  }
//
//  /** Updates the set connections attribute of the given hex. If this causes a change, relights */
//  public function setAcceptConnections(row : Int, col : Int, accept : Bool) : Board {
//    var h : Hex = get(row, col);
//    if (h != null) {
//      var currentlyAccepting = h.acceptConnections;
//      h.acceptConnections = accept;
//
//      if (currentlyAccepting != accept) {
//        relight();
//      }
//    }
//
//    return this;
//  }
}

/** Represents light of a given color being pushed to a given destination,
  * coming from the given direction
  **/
class LightPusher {

  public var color(default, null) : Color;
  public var destination(default, null) : Point;
  public var inDirection(default, null) : Int;

  private function new (destination : Point, c : Color, inDirection : Int) {
    this.destination = destination;
    color = c;
    this.inDirection = inDirection;
  }

  public static inline function get(startLoc : Point, c : Color, exitSide : Int) : LightPusher {
    return new LightPusher(startLoc.add(Point.NEIGHBOR_DELTAS[startLoc.col%2][exitSide]),
                           c, (exitSide + Std.int(Util.HEX_SIDES/2)).mod(Util.HEX_SIDES));
  }

  public inline function toString() : String {
    return "(" + destination + ", " + color + ", " + inDirection + ")";
  }

}