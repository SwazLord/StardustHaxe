package idv.cjcat.stardustextended.flashdisplay.bursters;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.geom.Matrix;
import openfl.Vector;
import openfl.display.BitmapData;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Bursts out particles with <code>target</code> properties being references to small rectangular fractions (cells) of a bitmap.
 *
 * <p>
 * Initially, these particles are positioned as a two-by-two array,
 * and stick tightly together to each other,
 * forming a complete bitmap as a whole.
 * </p>
 *
 * <p>
 * Adding any initalizers that set the <code>target</code> property essentially does nothing,
 * since this burster internally sets particles' targets to <code>Bitmap</code> objects.
 * </p>
 */
class BitmapBurster extends Burster {
	/**
	 * The width of a cell.
	 */
	public var cellWidth:Int;

	/**
	 * The height of a cell.
	 */
	public var cellHeight:Int;

	/**
	 * The X coordinate of the top-left corner of the top-left cell.
	 */
	public var offsetX:Float;

	/**
	 * The Y coordinate of the top-left corner of the top-left cell.
	 */
	public var offsetY:Float;

	public var bitmapData:BitmapData;

	public function new(cellWidth:Int = 10, cellHeight:Int = 10, offsetX:Float = 0, offsetY:Float = 0) {
		super();
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override public function createParticles(currentTime:Float):Vector<Particle> {
		if (bitmapData == null) {
			return null;
		}

		var rows:Int = Math.ceil(bitmapData.height / cellHeight);
		var columns:Int = Math.ceil(bitmapData.width / cellWidth);
		var particles:Vector<Particle> = factory.createParticles(rows * columns, currentTime);

		var index:Int = 0;
		var matrix:Matrix = new Matrix();
		var halfCellWidth:Float = 0.5 * cellWidth;
		var halfCellHeight:Float = 0.5 * cellHeight;
		var p:Particle;

		for (j in 0...rows) {
			for (i in 0...columns) {
				var cellBMPD:BitmapData = new BitmapData(cellWidth, cellHeight, true, 0);
				matrix.tx = -cellWidth * i;
				matrix.ty = -cellHeight * j;
				cellBMPD.draw(bitmapData, matrix);
				var cell:Bitmap = new Bitmap(cellBMPD);
				cell.x = -halfCellWidth;
				cell.y = -halfCellHeight;
				var sprite:Sprite = new Sprite();
				sprite.addChild(cell);

				p = particles[index];
				p.target = sprite;
				p.x = sprite.x = halfCellWidth + cellWidth * i + offsetX;
				p.y = sprite.y = halfCellHeight + cellHeight * j + offsetY;
			}
		}

		return particles;
	}
}
