package model;

import common.Equitable.EquitableUtils;
import common.*;

using common.IntExtender;

class Board extends Array2D<Hex> {

  @:isVar public static var DEFAULT_CONNECTION_GROUP(default, never) : Int = 0;

  private var sources : Array<Source>;
  private var sinks : Array<Sink>;
  private var score : Score;
  private var nextConnectionGroup : Int;

  /** True if Rotator onRotate shouldn't be called. Useful during whole-board manipulation */
  public var disableOnRotate : Bool;

  public function new(rows : Int = 0, cols : Int = 0) {
    super(rows, cols);
    sources = [];
    sinks = [];
    disableOnRotate = false;
    score = new Score();
    resetNextConnectionGroupCounter();
  }

  /** Equals function for boards. */
  public function equals(b : Board) : Bool {
    return this == b || (score.equals(b.getScore()) && super.equalsUsing(b, EquitableUtils.equalsFunc(Hex)));
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

  /** Returns the Hex at the given row,col. If safe, returns null if OOB */
  public override function get(row : Int, col : Int, safe : Bool = false) : Hex {
    return super.get(row, col, safe);
  }

  /** Returns the Hex at the given point */
  public override function getAt(p : Point, safe : Bool = false) : Hex {
    return super.getAt(p, safe);
  }

  /** One arg version of above for mapping */
  public inline function getAtUnsafe(p : Point) : Hex {
    return getAt(p, false);
  }

  /** One arg safe version of above for mapping */
  public inline function getAtSafe(p : Point) : Hex {
    return getAt(p, true);
  }

  /** In addition to calling super.set, updates sources/sinks as necessary */
  public override function set(row : Int, col : Int, h : Hex) : Hex {
    var oldH : Hex = get(row, col);

    super.set(row, col, h);

    //If h is a Rotator, make sure there are no adjacent Rotators to prevent infinite recursion
    if (h != null && oldH != h && h.isRotator()) {
      for (p in h.position.getNeighbors()) {
        if (getAt(p,true) != null && getAt(p,true).isRotator()) {
          super.set(row,col,oldH); //Undo setting before throwing
          throw "Can't have adjacent Rotators at " + h.position + " and " + p;
        }
      }
    }

    if (oldH != h) {
      if (oldH != null) {
        oldH.connectionGroup = Hex.UNSET_CONNECTION_GROUP;
        if (oldH.isSource()) {
          sources.remove(Std.instance(oldH,Source));
        } else if (oldH.isSink()) {
          sinks.remove(Std.instance(oldH,Sink));
        } else if (oldH.isRotator()) {
          oldH.rotationListener = null;
        }
      }
      if (h != null) {
        h.connectionGroup = DEFAULT_CONNECTION_GROUP;
        if (h.isSource()) {
          addSource(Std.instance(h,Source));
        } else if (h.isSink()) {
          addSink(Std.instance(h,Sink));
        } else if (h.isRotator()) {
          h.rotationListener = onRotatorRotate;
        }
      }
    }
    return h;
  }

  public override function remove(r : Int, c : Int) : Hex {
    var h : Hex = super.remove(r,c);
    if (h != null && h.isSource()) sources.remove(h.asSource());
    if (h != null && h.isSink()) sinks.remove(h.asSink());
    return h;
  }

  /** In addition to calling super.swap, updates sources/sinks as necessary */
  public override function swap(p1 : Point, p2 : Point) : Board {
    super.swap(p1, p2);

    var h1 = getAt(p1);
    var h2 = getAt(p2);

    if (h1 != null) {
      if (h1.isSource()) {
        addSource(Std.instance(h1,Source), true);
      } else if (h1.isSink()) {
        addSink(Std.instance(h1,Sink), true);
      } else if (h1.isRotator()) {
        h1.rotationListener = onRotatorRotate;
      }
    }

    if (h2 != null) {
      if (h2.isSource()) {
        addSource(Std.instance(h2,Source), true);
      } else if (h2.isSink()) {
        addSink(Std.instance(h2,Sink), true);
      } else if (h2.isRotator()) {
        h2.rotationListener = onRotatorRotate;
      }
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

  /** Listener set when a rotator is added to this board
   *  Swaps hexes around this by the same amount that this was rotated.
   *  Also rotates hexes by that amount so that their orientation stays
   *  constant with respect to h as the rotational center.
   **/
  private function onRotatorRotate(h : Hex, i : Int) : Void {
    if(! h.isRotator()) throw "expected Rotator, have " + h;

    if (! disableOnRotate) {
      //Update orientations of hexes to be moved this way
      for(p in h.position.getNeighbors()) {
        var n = getAt(p, true);
        if (n != null) {
          n.orientation += (h.orientation - i);
        }
      }

      //Move hexes
      while(i < h.orientation) {
        swapManyBackward(h.position.getNeighbors());
        i++;
      }
      while(i > h.orientation) {
        swapManyForward(h.position.getNeighbors());
        i--;
      }
    }
  }

  /** Overridden to narrow return type */
  public override function fillWith(elmCreator : Void->Hex) : Board {
    super.fillWith(elmCreator);
    return this;
  }

  /** Returns a reference to the score object stored in this Board */
  public inline function getScore() : Score {
    return score;
  }

  /** Resets the next connection group to 1, the non-default connection group. Returns this */
  public inline function resetNextConnectionGroupCounter() : Board {
    nextConnectionGroup = 1;
    return this;
  }

  /** Resets the hexes at the given locations to the DEFAULT_CONNECTION_GROUP. Returns this */
  public inline function resetToDefaultConnectionGroup(locations : Array<Point>) : Board {
    for(pt in locations) {
      var h = getAt(pt);
      if (h != null) {
        h.connectionGroup = DEFAULT_CONNECTION_GROUP;
      }
    }
    return this;
  }

  /** Sets each of the hexes at the given locations as the next connection group.
   * Ignores locations with null hexes.
   * Returns the connection group ID this new group belongs to.
   **/
  public inline function setAsNextConnectionGroup(locations : Array<Point>) : Int {
    for(pt in locations) {
      var h = getAt(pt);
      if (h != null) {
        h.connectionGroup = nextConnectionGroup;
      }
    }
    nextConnectionGroup++;
    return (nextConnectionGroup-1);
  }

  /** Causes the board to relight entirely.
   * Arg is a mask of which sources are currently pushing light. If null, all are on.
   * Returns the score object stored in this board, updated with the new lighting.
   **/
  public function relight(sourceMask : Map<Point, Bool> = null) : Score {
    score.reset();

    //First, remove light from the whole board.
    for(h in this) {
      h.resetLight();
    }

    var queue : Array<LightPusher> = [];
    //Setup - all sources push their color of light out in all directions
    for(s in sources) {
      s.updateLightOut();
      if (sourceMask == null || sourceMask.get(s.position)){
        for(i in 0...Util.HEX_SIDES) {
          queue.push(LightPusher.get(s.position, s.getCurrentColor(), i, s.connectionGroup));
        }
      }
    }

    //Iteration - pop light pusher, push light in, add pushers for any continuing light
    while (queue.length > 0) {
      var l = queue.shift();
      var h : Hex = getAt(l.destination, true);
      if (h != null && h.connectionGroup == l.connectionGroup) {
        var newOut = h.addLightIn(l.inDirection,l.color);
        for (x in newOut) {
          if (h.getLightOut(x) != Color.NONE) {
            queue.push(LightPusher.get(h.position,h.getLightOut(x),x,h.connectionGroup));
          }
        }
      }
    }
    for (sink in sinks) {
      if (sink.getCurrentColor() != Color.NONE) {
        score.increment(sink.getCurrentColor());
      }
    }
    return score;
  }
}

/** Represents light of a given color being pushed to a given destination,
  * coming from the given direction
  **/
class LightPusher {

  public var color(default, null) : Color;
  public var destination(default, null) : Point;
  public var inDirection(default, null) : Int;
  public var connectionGroup(default, null) : Int;

  private function new (destination : Point, c : Color, inDirection : Int, connectionGroup : Int) {
    this.destination = destination;
    color = c;
    this.inDirection = inDirection;
    this.connectionGroup = connectionGroup;
  }

  public static inline function get(startLoc : Point, c : Color, exitSide : Int, connectionGroup : Int) : LightPusher {
    return new LightPusher(startLoc.add(Point.NEIGHBOR_DELTAS[startLoc.col%2][exitSide]),
                           c, (exitSide + Std.int(Util.HEX_SIDES/2)).mod(Util.HEX_SIDES), connectionGroup);
  }

  public inline function toString() : String {
    return "(" + destination + ", " + color + ", " + inDirection + ")";
  }

}
