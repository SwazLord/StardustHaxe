package idv.cjcat.stardustextended.handlers.starling;

import openfl.system.ApplicationDomain;
import openfl.display3D.Context3DBufferUsage;
import starling.core.Starling;
import starling.errors.MissingContextError;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.utils.ByteArray;

class StarlingParticleBuffers {
	public static var vertexBuffer(get, never):VertexBuffer3D;
	public static var indexBuffer:IndexBuffer3D;
	private static var vertexBuffers:Vector<VertexBuffer3D>;
	private static var indices:Vector<UInt>;
	private static var sNumberOfVertexBuffers:Int;

	private static var _vertexBufferIdx:Int = -1;
	private static inline final ELEMENTS_PER_VERTEX:Int = 8;

	/** Creates buffers for the simulation.
	 * numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering. Multi buffering
	 * can avoid stalling of the GPU but will also increases it's memory consumption. */
	public static function createBuffers(numParticles:UInt, numberOfVertexBuffers:Int):Void {
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

		if (context == null)
			throw new MissingContextError();
		if (context.driverInfo == "Disposed")
			return;

		vertexBuffers = new Vector<VertexBuffer3D>();

		if (ApplicationDomain.currentDomain.hasDefinition("openfl.display3D.Context3DBufferUsage")) {
			// if (Type.getClassName(Type.getClass(Context3D)) == "openfl.display3D.Context3DBufferUsage") {
			for (i in 0...sNumberOfVertexBuffers) {
				vertexBuffers[i] = context.createVertexBuffer(numParticles * 4, ELEMENTS_PER_VERTEX, "dynamicDraw");
			}
		} else {
			for (i in 0...sNumberOfVertexBuffers) {
				vertexBuffers[i] = context.createVertexBuffer(numParticles * 4, ELEMENTS_PER_VERTEX);
			}
		}

		var zeroBytes = new ByteArray();
		zeroBytes.length = numParticles * 16 * ELEMENTS_PER_VERTEX;

		for (i in 0...sNumberOfVertexBuffers) {
			vertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, numParticles * 4);
		}

		zeroBytes.length = 0;

		if (indices == null) {
			indices = new Vector<UInt>();
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
	@:inline
	public static function switchVertexBuffer():Void {
		_vertexBufferIdx = ++_vertexBufferIdx % sNumberOfVertexBuffers;
	}

	@:inline
	public static function get_vertexBuffer():VertexBuffer3D {
		return vertexBuffers[_vertexBufferIdx];
	}

	@:inline
	public static function get_vertexBufferIdx():UInt {
		return _vertexBufferIdx;
	}

	private static var _buffersCreated:Bool;

	public static var buffersCreated(get, never):Bool;

	@:inline
	public static function get_buffersCreated():Bool {
		// this has to look like this otherwise ASC 2.0 generates some garbage code
		return vertexBuffers != null && vertexBuffers.length > 0;
	}
}
