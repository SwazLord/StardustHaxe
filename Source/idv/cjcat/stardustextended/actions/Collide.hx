package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Causes particles to collide against each other.
 *
 * <p>
 * The <code>maxDistance</code> property is calculated in each <code>preUpdate()</code> call,
 * so altering this value manually does no effect on the collision.
 * </p>
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
class Collide extends MutualAction {
	public function new() {
		super();
		priority = -6;

		maxDistance = 0;
	}

	/**
	 * Calculates the optimal <code>maxDistance</code> value for maximum efficiency.
	 * @param    emitter
	 * @param    time
	 */
	override public function preUpdate(emitter:Emitter, time:Float):Void // find the largest two particles
	{
		if (emitter.particles.length <= 1) {
			return;
		}

		var max1:Float = 0;
		var max2:Float = 0;
		var r:Float;
		var p:Particle;
		var plen:Int = emitter.particles.length;
		for (m in 0...plen) {
			p = emitter.particles[m];
			r = p.collisionRadius * p.scale;
			if (r > max1) {
				max2 = max1;
				max1 = r;
			} else if (r > max2) {
				max2 = r;
			}
		}
		maxDistance = max1 + max2;
	}

	override private function doMutualAction(p1:Particle, p2:Particle, time:Float):Void {
		var dx:Float = p1.x - p2.x;
		var dy:Float = p1.y - p2.y;
		var r1:Float = p1.collisionRadius * p1.scale;
		var r2:Float = p2.collisionRadius * p2.scale;
		var collisionDist:Float = r1 + r2;
		if (dx * dx + dy * dy > collisionDist * collisionDist) {
			return;
		}

		// collision detected
		// adjust positions
		var r:Vec2D = Vec2DPool.get(dx, dy);
		var collisionDist_inv:Float = 1 / collisionDist;
		var xAvg:Float = (p1.x * r2 + p2.x * r1) * collisionDist_inv;
		var yAvg:Float = (p1.y * r2 + p2.y * r1) * collisionDist_inv;

		r.length = r1;
		p1.x = xAvg + r.x;
		p1.y = yAvg + r.y;

		r.length = r2;
		p2.x = xAvg - r.x;
		p2.y = yAvg - r.y;

		// adjust velocities
		var m1:Float = p1.mass * p1.scale;
		var m2:Float = p2.mass * p2.scale;
		var massSum_inv:Float = 1 / (m1 + m2);
		var v1p:Vec2D = Vec2DPool.get(p1.vx, p1.vy);
		var v2p:Vec2D = Vec2DPool.get(p2.vx, p2.vy);
		v1p.projectThis(r);
		v2p.projectThis(r);
		var v1n:Vec2D = Vec2DPool.get(p1.vx - v1p.x, p1.vy - v1p.y);
		var v2n:Vec2D = Vec2DPool.get(p2.vx - v2p.x, p2.vy - v2p.y);
		var vTotal:Vec2D = Vec2DPool.get(v1p.x - v2p.x, v1p.y - v2p.y);
		var massDiff:Float = m1 - m2;

		v1p.x = (massDiff * v1p.x + 2 * m2 * v2p.x) * massSum_inv;
		v1p.y = (massDiff * v1p.y + 2 * m2 * v2p.y) * massSum_inv;
		v2p.x = vTotal.x + v1p.x;
		v2p.y = vTotal.y + v1p.y;

		p1.vx = v1p.x + v1n.x;
		p1.vy = v1p.y + v1n.y;
		p2.vx = v2p.x + v2n.x;
		p2.vy = v2p.y + v2n.y;

		Vec2DPool.recycle(r);
		Vec2DPool.recycle(v1p);
		Vec2DPool.recycle(v2p);
		Vec2DPool.recycle(v1n);
		Vec2DPool.recycle(v2n);
		Vec2DPool.recycle(vTotal);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Collide";
	}
}
