package com.funkypandagame.stardustplayer;

import idv.cjcat.stardustextended.particles.Particle;

// could be a dynamic class that writes only the needed properties, but it might be slow
class Particle2DSnapshot
{
    
    public var x : Float;
    public var y : Float;
    public var vx : Float;
    public var vy : Float;
    public var rotation : Float;
    public var omega : Float;
    public var initLife : Float;
    public var initScale : Float;
    public var initAlpha : Float;
    public var life : Float;
    public var scale : Float;
    public var alpha : Float;
    public var mass : Float;
    public var isDead : Bool;
    public var colorR : Float;
    public var colorG : Float;
    public var colorB : Float;
    
    public var currentAnimationFrame : Int;
    
    public function storeParticle(p2d : Particle) : Void
    {
        x = toLowPrecision(p2d.x);
        y = toLowPrecision(p2d.y);
        vx = toLowPrecision(p2d.vx);
        vy = toLowPrecision(p2d.vy);
        rotation = toLowPrecision(p2d.rotation);
        omega = toLowPrecision(p2d.omega);
        initLife = toLowPrecision(p2d.initLife);
        initScale = toLowPrecision(p2d.initScale);
        initAlpha = toLowPrecision(p2d.initAlpha);
        life = toLowPrecision(p2d.life);
        scale = toLowPrecision(p2d.scale);
        alpha = toLowPrecision(p2d.alpha);
        mass = toLowPrecision(p2d.mass);
        isDead = p2d.isDead;
        colorR = toLowPrecision(p2d.colorR);
        colorG = toLowPrecision(p2d.colorG);
        colorB = toLowPrecision(p2d.colorB);
        currentAnimationFrame = p2d.currentAnimationFrame;
    }
    
    // round to the last 3 decimals, this improves compression
    private static function toLowPrecision(num : Float) : Float
    {
        return Std.int(num * 1000) * 0.001;
    }
    
    public function writeDataTo(p2d : Particle) : Void
    {
        p2d.x = x;
        p2d.y = y;
        p2d.vx = vx;
        p2d.vy = vy;
        p2d.rotation = rotation;
        p2d.omega = omega;
        p2d.initLife = initLife;
        p2d.initScale = initScale;
        p2d.initAlpha = initAlpha;
        p2d.life = life;
        p2d.scale = scale;
        p2d.alpha = alpha;
        p2d.mass = mass;
        p2d.isDead = isDead;
        p2d.colorR = colorR;
        p2d.colorG = colorG;
        p2d.colorB = colorB;
        p2d.currentAnimationFrame = currentAnimationFrame;
    }

    public function new()
    {
    }
}

