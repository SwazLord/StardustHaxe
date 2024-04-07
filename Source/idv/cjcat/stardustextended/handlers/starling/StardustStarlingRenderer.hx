package idv.cjcat.stardustextended.handlers.starling;

import starling.utils.MathUtil;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;
import openfl.Vector;
import starling.events.Event;
import openfl.geom.Rectangle;
import idv.cjcat.stardustextended.particles.Particle;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.filters.FragmentFilter;
import starling.rendering.Painter;
import starling.textures.Texture;

class StardustStarlingRenderer extends DisplayObject {
	/** The offset of position data (x, y) within a vertex. */
	private static inline var POSITION_OFFSET:Int = 0;

	/** The offset of color data (r, g, b, a) within a vertex. */
	private static inline var COLOR_OFFSET:Int = 2;

	/** The offset of texture coordinates (u, v) within a vertex. */
	private static inline var TEXCOORD_OFFSET:Int = 6;

	public static inline var MAX_POSSIBLE_PARTICLES:Int = 16383;
	private static var DEGREES_TO_RADIANS:Float = Math.PI / 180;
	private static var sCosLUT:Vector<Float> = new Vector<Float>();
	private static var sSinLUT:Vector<Float> = new Vector<Float>();
	private static var renderAlpha:Vector<Float> = new Vector<Float>();

	private static var numberOfVertexBuffers:Int;
	private static var maxParticles:Int;
	private static var initCalled:Bool = false;

	private var boundsRect:Rectangle;
	private var mFilter:FragmentFilter;
	private var mTexture:Texture;
	private var mBatched:Bool;
	private var vertexes:Vector<Float>;
	private var frames:Vector<Frame>;

	public var mNumParticles:Int = 0;
	public var texSmoothing:String;
	public var premultiplyAlpha:Bool = true;

	private var _id:Float;

	public function new() {
		super();
		if (initCalled == false) {
			init();
		}

		vertexes = new Vector<Float>();
	}

	/** numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering.
	 *  Multi buffering can avoid stalling of the GPU but will also increases it's memory consumption.
	 *  If you want to avoid stalling create the same amount of buffers as your maximum rendered emitters at the
	 *  same time.
	 *  Allocating one buffer with the maximum amount of particles (16383) takes up 2048KB(2MB) GPU memory.
	 *  This call requires that there is a Starling context
	**/
	public static function init(numberOfBuffers:Int = 2, maxParticlesPerBuffer:Int = MAX_POSSIBLE_PARTICLES):Void {
		numberOfVertexBuffers = numberOfBuffers;

		if (maxParticlesPerBuffer > MAX_POSSIBLE_PARTICLES) {
			maxParticlesPerBuffer = MAX_POSSIBLE_PARTICLES;
			trace("StardustStarlingRenderer WARNING: Tried to render than 16383 particles, setting value to 16383");
		}

		maxParticles = maxParticlesPerBuffer;
		StarlingParticleBuffers.createBuffers(maxParticlesPerBuffer, numberOfBuffers);

		if (!initCalled) {
			for (i in 0...0x800) {
				sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
				sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
			}

			// handle a lost device context
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			initCalled = true;
		}
	}

	private static function onContextCreated(event:Event):Void {
		StarlingParticleBuffers.createBuffers(maxParticles, numberOfVertexBuffers);
	}

	public function setTextures(texture:Texture, _frames:Vector<Frame>):Void {
		mTexture = texture;
		frames = _frames;
	}

	private var particle:Particle;
	private var vertexID:Int = 0;

	private var red:Float;
	private var green:Float;
	private var blue:Float;
	private var particleAlpha:Float;

	private var _rotation:Float;
	private var xPos:Float;
	private var yPos:Float;
	private var xOffset:Float;
	private var yOffset:Float;

	private var angle:Int;
	private var cos:Float;
	private var sin:Float;
	private var cosX:Float;
	private var cosY:Float;
	private var sinX:Float;
	private var sinY:Float;
	private var position:Int;
	private var frame:Frame;
	private var bottomRightX:Float;
	private var bottomRightY:Float;
	private var topLeftX:Float;
	private var topLeftY:Float;

	private var _i:Int;

	inline final public function advanceTime(mParticles:Vector<Particle>):Void {
		mNumParticles = mParticles.length;
		vertexes.fixed = false;
		vertexes.length = mNumParticles * 32;
		vertexes.fixed = true;

		for (_i in 0...mNumParticles) {
			vertexID = _i << 2;
			particle = mParticles[_i];

			// color & alpha
			particleAlpha = particle.alpha;

			if (premultiplyAlpha) {
				red = particle.colorR * particleAlpha;
				green = particle.colorG * particleAlpha;
				blue = particle.colorB * particleAlpha;
			} else {
				red = particle.colorR;
				green = particle.colorG;
				blue = particle.colorB;
			}

			// position & rotation
			_rotation = particle.rotation * DEGREES_TO_RADIANS;
			xPos = particle.x;
			yPos = particle.y;
			// texture
			frame = frames[particle.currentAnimationFrame];
			bottomRightX = frame.bottomRightX;
			bottomRightY = frame.bottomRightY;
			topLeftX = frame.topLeftX;
			topLeftY = frame.topLeftY;
			xOffset = frame.particleHalfWidth * particle.scale;
			yOffset = frame.particleHalfHeight * particle.scale;

			position = vertexID << 3; // * 8

			if (_rotation != 0 && !Math.isNaN(_rotation)) {
				angle = Std.int(_rotation * 325.94932345220164765467394738691) & 2047;
				cos = sCosLUT[angle];
				sin = sSinLUT[angle];
				cosX = cos * xOffset;
				cosY = cos * yOffset;
				sinX = sin * xOffset;
				sinY = sin * yOffset;

				vertexes[position] = xPos - cosX + sinY; // 0,1: position (in pixels)
				vertexes[++position] = yPos - sinX - cosY;
				vertexes[++position] = red; // 2,3,4,5: Color and Alpha [0-1]
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = topLeftX; // 6,7: Texture coords [0-1]
				vertexes[++position] = topLeftY;

				vertexes[++position] = xPos + cosX + sinY;
				vertexes[++position] = yPos + sinX - cosY;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = bottomRightX;
				vertexes[++position] = topLeftY;

				vertexes[++position] = xPos - cosX - sinY;
				vertexes[++position] = yPos - sinX + cosY;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = topLeftX;
				vertexes[++position] = bottomRightY;

				vertexes[++position] = xPos + cosX - sinY;
				vertexes[++position] = yPos + sinX + cosY;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = bottomRightX;
				vertexes[++position] = bottomRightY;
			} else {
				vertexes[position] = xPos - xOffset;
				vertexes[++position] = yPos - yOffset;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = topLeftX;
				vertexes[++position] = topLeftY;

				vertexes[++position] = xPos + xOffset;
				vertexes[++position] = yPos - yOffset;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = bottomRightX;
				vertexes[++position] = topLeftY;

				vertexes[++position] = xPos - xOffset;
				vertexes[++position] = yPos + yOffset;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = topLeftX;
				vertexes[++position] = bottomRightY;

				vertexes[++position] = xPos + xOffset;
				vertexes[++position] = yPos + yOffset;
				vertexes[++position] = red;
				vertexes[++position] = green;
				vertexes[++position] = blue;
				vertexes[++position] = particleAlpha;
				vertexes[++position] = bottomRightX;
				vertexes[++position] = bottomRightY;
			}
		}
	}

	@inline
	final private function isStateChange(texture:TextureBase, smoothing:String, blendMode:String, filter:FragmentFilter, premultiplyAlpha:Bool,
			numParticles:Int):Bool {
		if (mNumParticles == 0) {
			return false;
		} else if (mNumParticles + numParticles > MAX_POSSIBLE_PARTICLES) {
			return true;
		} else if (mTexture != null && texture != null) {
			return mTexture.base != texture
				|| texSmoothing != smoothing
				|| this.blendMode != blendMode
				|| mFilter != filter
				|| this.premultiplyAlpha != premultiplyAlpha;
		}

		return true;
	}

	override public function render(painter:Painter):Void {
		painter.excludeFromCache(this); // for some reason it doesnt work if inside the if. Starling bug?

		if (mNumParticles > 0 && !mBatched) {
			var mNumBatchedParticles:Int = batchNeighbours();
			var parentAlpha:Float = if (parent != null) parent.alpha else 1.0;
			renderCustom(painter, mNumBatchedParticles, parentAlpha);
		}

		// reset filter
		super.filter = mFilter;
		mBatched = false;
	}

	inline final private function batchNeighbours():Int {
		var mNumBatchedParticles:Int = 0;
		var last:Int = parent.getChildIndex(this);
		var isStateChange:Bool;

		var targetIndex:Int;
		var sourceIndex:Int;
		var sourceEnd:Int;

		while (++last < parent.numChildren) {
			var nextPS:StardustStarlingRenderer = try cast(parent.getChildAt(last), StardustStarlingRenderer) catch (e:Dynamic) null;

			isStateChange = nextPS.isStateChange(mTexture.base, texSmoothing, blendMode, mFilter, premultiplyAlpha, mNumParticles);

			if (nextPS != null && !isStateChange) {
				if (nextPS.mNumParticles > 0) {
					vertexes.fixed = false;

					targetIndex = Std.int((mNumParticles + mNumBatchedParticles) * 32); // 4 * 8
					sourceIndex = 0;
					sourceEnd = Std.int(nextPS.mNumParticles * 32); // 4 * 8

					while (sourceIndex < sourceEnd) {
						vertexes[targetIndex++] = nextPS.vertexes[sourceIndex++];
					}

					vertexes.fixed = true;

					mNumBatchedParticles += nextPS.mNumParticles;

					nextPS.mBatched = true;

					// disable filter of batched system temporarily
					nextPS.filter = null;
				}
			} else {
				break;
			}
		}

		return mNumBatchedParticles;
	}

	private function renderCustom(painter:Painter, mNumBatchedParticles:Int, parentAlpha:Float):Void {
		if (mNumParticles == 0 || StarlingParticleBuffers.buffersCreated == false) {
			return;
		}

		if (mNumBatchedParticles > maxParticles) {
			trace("Over " + maxParticles + " particles! Aborting rendering");
			return;
		}

		StarlingParticleBuffers.switchVertexBuffer();

		var context:Context3D = Starling.current.context;

		if (context == null) {
			throw new MissingContextError();
		}

		painter.finishMeshBatch();
		painter.drawCount += 1;
		painter.prepareToDraw();

		BlendMode.get(blendMode).activate();

		renderAlpha[0] = renderAlpha[1] = renderAlpha[2] = (premultiplyAlpha) ? parentAlpha : 1;
		renderAlpha[3] = parentAlpha;

		ParticleProgram.getProgram(mTexture.mipMapping, mTexture.format, texSmoothing).activate(); // calls context.setProgram(_program3D);
		context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, renderAlpha, 1);
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, painter.state.mvpMatrix3D, true);

		context.setTextureAt(0, mTexture.base);
		StarlingParticleBuffers.vertexBuffer.uploadFromVector(vertexes, 0, MathUtil.minInt(maxParticles * 4, Std.int(vertexes.length / 8)));
		context.setVertexBufferAt(0, StarlingParticleBuffers.vertexBuffer, POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
		context.setVertexBufferAt(1, StarlingParticleBuffers.vertexBuffer, COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
		context.setVertexBufferAt(2, StarlingParticleBuffers.vertexBuffer, TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

		context.drawTriangles(StarlingParticleBuffers.indexBuffer, 0, (MathUtil.minInt(maxParticles, mNumParticles + mNumBatchedParticles)) * 2);

		context.setVertexBufferAt(0, null);
		context.setVertexBufferAt(1, null);
		context.setVertexBufferAt(2, null);
		context.setTextureAt(0, null);
	}

	override private function set_filter(value:FragmentFilter):FragmentFilter {
		if (!mBatched) {
			mFilter = value;
		}

		super.filter = value;
		return value;
	}

	/**
	 * Stardust does not calculate the bounds of the simulation. In the future this would be possible, but
	 * will be a performance heavy operation.
	 */
	override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
		if (boundsRect == null) {
			boundsRect = new Rectangle();
		}

		return boundsRect;
	}
}
