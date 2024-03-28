package idv.cjcat.stardustextended.flashdisplay.utils;

import openfl.errors.IllegalOperationError;

/**
 * Class for construct
 */
class Construct {
	/**
	 * Creates an object of a class with provided parameters.
	 * @param    classObj    The class.
	 * @param    params        The parameters.
	 * @return                The object.
	 */
	public static function construct(classObj:Class<Dynamic>, params:Array<Dynamic> = null):Dynamic {
		if (params == null) {
			return Type.createInstance(classObj, []);
		}

		var _sw0_ = (params.length);

		switch (_sw0_) {
			case 0:
				return Type.createInstance(classObj, []);

			case 1:
				return Type.createInstance(classObj, [params[0]]);

			case 2:
				return Type.createInstance(classObj, [params[0], params[1]]);

			case 3:
				return Type.createInstance(classObj, [params[0], params[1], params[2]]);

			case 4:
				return Type.createInstance(classObj, [params[0], params[1], params[2], params[3]]);

			case 5:
				return Type.createInstance(classObj, [params[0], params[1], params[2], params[3], params[4]]);

			case 6:
				return Type.createInstance(classObj, [params[0], params[1], params[2], params[3], params[4], params[5]]);

			case 7:
				return Type.createInstance(classObj, [params[0], params[1], params[2], params[3], params[4], params[5], params[6]]);

			case 8:
				return Type.createInstance(classObj, [
					params[0],
					params[1],
					params[2],
					params[3],
					params[4],
					params[5],
					params[6],
					params[7]
				]);

			case 9:
				return Type.createInstance(classObj, [
					params[0],
					params[1],
					params[2],
					params[3],
					params[4],
					params[5],
					params[6],
					params[7],
					params[8]
				]);

			case 10:
				return Type.createInstance(classObj, [
					params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9]]);
			default:
				throw new IllegalOperationError("The number of parameters given exceeds the maximum number this method can handle.");
		}
	}
}
