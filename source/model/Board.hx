package model;

import common.Point;
import common.Array2D;
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

}