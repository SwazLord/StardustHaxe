package idv.cjcat.stardustextended.handlers.starling;


class Frame
{
    
    public var particleHalfWidth : Float;
    public var particleHalfHeight : Float;
    public var topLeftX : Float;
    public var topLeftY : Float;
    public var bottomRightX : Float;
    public var bottomRightY : Float;
    
    public function new(_topLeftX : Float,
            _topLeftY : Float,
            _bottomRightX : Float,
            _bottomRightY : Float,
            _halfWidth : Float,
            _halfHeight : Float)
    {
        topLeftX = _topLeftX;
        topLeftY = _topLeftY;
        bottomRightX = _bottomRightX;
        bottomRightY = _bottomRightY;
        particleHalfWidth = _halfWidth;
        particleHalfHeight = _halfHeight;
    }
}

