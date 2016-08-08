package;

//Tests are run from inner folder, have to move back one level to find assets
#if RUN_TESTS
@:build(flixel.system.FlxAssets.buildFileReferences("../assets", true))
#else
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
#end
class AssetPaths {}
