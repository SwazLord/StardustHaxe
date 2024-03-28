package idv.cjcat.stardustextended.handlers.starling;

import openfl.Vector;
import openfl.display3D.IndexBuffer3D;
import openfl.system.ApplicationDomain;
import openfl.display3D.VertexBuffer3D;
import openfl.display3D.Context3D;
import openfl.utils.ByteArray;
import starling.core.Starling;
import starling.errors.MissingContextError;

class StarlingParticleBuffers {
	public static var vertexBuffer(get, never):VertexBuffer3D;
	public static var vertexBufferIdx(get, never):Int;
	public static var buffersCreated(get, never):Bool;

	public static var indexBuffer:IndexBuffer3D;
	private static var vertexBuffers:Array<VertexBuffer3D>;
	private static var indices:Vector<Int>;
	private static var sNumberOfVertexBuffers:Int;
	private static var _vertexBufferIdx:Int = -1;
	private static inline var ELEMENTS_PER_VERTEX:Int = 8;

	/** Creates buffers for the simulation.
	 * numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering. Multi buffering
	 * can avoid stalling of the GPU but will also increases it's memory consumption. */
	public static function createBuffers(numParticles:Int, numberOfVertexBuffers:Int):Void {
		sNumberOfVertexBuffers = numberOfVertexBuffers;
		_vertexBufferIdx = -1;

		if (vertexBuffers != null) {
			for (i in 0...vertexBuffers.length) {
				vertexBuffers[i].dispose();
			}
		}

		if (indexBuffer != null) {
			indexBuffer.dispose();
		}

		var context:Context3D = Starling.currentContext;

		if (context == null) {
			throw new MissingContextError();
		}
		if (context.driverInfo == "Disposed") {
			return;
		}

		vertexBuffers = new Array<VertexBuffer3D>();

		if (ApplicationDomain.currentDomain.hasDefinition("flash.display3D.Context3DBufferUsage")) {
			for (i in 0...sNumberOfVertexBuffers) {
				// Context3DBufferUsage.DYNAMIC_DRAW; hardcoded for FP 11.x compatibility{

				vertexBuffers[i] = context.createVertexBuffer.call(context, numParticles * 4, ELEMENTS_PER_VERTEX, "dynamicDraw");
			}
		} else {
			for (i in 0...sNumberOfVertexBuffers) {
				vertexBuffers[i] = context.createVertexBuffer(numParticles * 4, ELEMENTS_PER_VERTEX);
			}
		}

		var zeroBytes:ByteArray = new ByteArray();
		zeroBytes.length = numParticles * 16 * ELEMENTS_PER_VERTEX;

		for (i in 0...sNumberOfVertexBuffers) {
			vertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, numParticles * 4);
		}

		zeroBytes.length = 0;

		if (indices == null) {
			indices = new Vector<Int>();
			var numVertices:Int = 0;
			var indexPosition:Int = -1;

			for (i in 0...numParticles) {
				indices[++indexPosition] = numVertices;
				indices[++indexPosition] = numVertices + 1;
				indices[++indexPosition] = numVertices + 2;

				indices[++indexPosition] = numVertices + 1;
				indices[++indexPosition] = numVertices + 3;
				indices[++indexPosition] = numVertices + 2;
				numVertices += 4;
			}
		}

		indexBuffer = context.createIndexBuffer(numParticles * 6);
		indexBuffer.uploadFromVector(indices, 0, numParticles * 6);
	}

	/** Call this function to switch to the next Vertex buffer before calling uploadFromVector() to implement multi
	 *  buffering. Has only effect if numberOfVertexBuffers > 1 */
	inline public static function switchVertexBuffer():Void {
		_vertexBufferIdx = as3hx.Compat.parseInt(++_vertexBufferIdx % sNumberOfVertexBuffers);
	}

	inline private static function get_vertexBuffer():VertexBuffer3D {
		return vertexBuffers[_vertexBufferIdx];
	}

	inline private static function get_vertexBufferIdx():Int {
		return _vertexBufferIdx;
	}

	inline private static function get_buffersCreated():Bool // this has to look like this otherwise ASC 2.0 generates some garbage code
	{
		if (vertexBuffers != null && vertexBuffers.length > 0) {
			return true;
		}

		return false;
	}

	public function new() {}
}
