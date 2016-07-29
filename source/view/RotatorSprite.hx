package view;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

/** A RotatorSprite is treated like a PrismSprite with no connections */
class RotatorSprite extends RotatableHexSprite {

  public var rotationGroup(default, null) : FlxTypedSpriteGroup<HexSprite>;

  /** The orientation of this RotatorSprite when it started rotating */
  public var orientationAtRotationStart(default, default) : Int;

  public function new(x : Float = 0, y : Float = 0) {
    super(x,y);

    //Graphics
    loadGraphic(AssetPaths.rotator_back__png);

    //TODO - use rotateGraphic and animations to increase speed
    //    loadRotatedGraphic(AssetPaths.hex_back__png, Std.int(360.0/ROTATION_INC));

    rotationGroup = new FlxTypedSpriteGroup<HexSprite>();
  }

  public override function update(dt : Float) {
    super.update(dt);

//    rotationGroup.angle = angle;
  }

}
