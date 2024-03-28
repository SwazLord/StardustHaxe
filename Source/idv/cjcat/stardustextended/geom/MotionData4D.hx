package idv.cjcat.stardustextended.geom;


/**
 * 4D vector value class.
 */
class MotionData4D
{
    public var x : Float;
    public var y : Float;
    public var vx : Float;
    public var vy : Float;
    
    public function new(x : Float = 0, y : Float = 0, vx : Float = 0, vy : Float = 0)
    {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
    }
}
