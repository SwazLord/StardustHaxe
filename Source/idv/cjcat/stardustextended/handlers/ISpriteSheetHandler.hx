package idv.cjcat.stardustextended.handlers;


interface ISpriteSheetHandler
{
    
    
    
    
    var spriteSheetAnimationSpeed(get, set) : Int;    
    
    
    
    var spriteSheetStartAtRandomFrame(get, set) : Bool;    
    
    
    
    var smoothing(get, set) : Bool;    
    
    var isSpriteSheet(get, never) : Bool;    
    
    
    
    var blendMode(get, set) : String;

}

