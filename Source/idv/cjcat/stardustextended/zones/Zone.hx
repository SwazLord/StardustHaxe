package idv.cjcat.stardustextended.zones;

import openfl.errors.Error;
import openfl.geom.Point;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * This class defines a 2D zone.
 *
 * <p>
 * The <code>calculateMotionData2D()</code> method returns a <code>MotionData2D</code> object
 * which corresponds to a random point within the zone.
 * </p>
 */
class Zone extends StardustElement implements IPosition {
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var rotation(get, set):Float;

	private var _rotation:Float;
	private var angleCos:Float;
	private var angleSin:Float;
	private var area:Float;

	private var position(default, never):Point = new Point();

	private var _x:Float;

	private function get_x():Float {
		return _x;
	}

	private function set_x(value:Float):Float {
		_x = value;
		return value;
	}

	private var _y:Float;

	private function get_y():Float {
		return _y;
	}

	private function set_y(value:Float):Float {
		_y = value;
		return value;
	}

	public function new() {
		super();
		rotation = 0;
	}

	/**
	 * [Abstract Method] Updates the area of the zone.
	 */
	private function updateArea():Void { // abstract method
	}

	/**
	 * [Abstract Method] Determines if a point is contained in the zone, true if contained.
	 * @param    x
	 * @param    y
	 * @return
	 */
	public function contains(x:Float, y:Float):Bool // abstract method
	{
		return false;
	}

	/**
	 * Returns a random point in the zone.
	 * @return
	 */
	public function getPoint():MotionData2D {
		var md2D:MotionData2D = calculateMotionData2D();
		if (_rotation != 0) {
			var originalX:Float = md2D.x;
			md2D.x = originalX * angleCos - md2D.y * angleSin;
			md2D.y = originalX * angleSin + md2D.y * angleCos;
		}
		md2D.x = _x + md2D.x;
		md2D.y = _y + md2D.y;
		return md2D;
	}

	private function get_rotation():Float {
		return _rotation;
	}

	private function set_rotation(value:Float):Float {
		var valInRad:Float = value * StardustMath.DEGREE_TO_RADIAN;
		angleCos = Math.cos(valInRad);
		angleSin = Math.sin(valInRad);
		_rotation = value;
		return value;
	}

	/**
	 * [Abstract Method] Returns a <code>MotionData2D</code> object representing a random point in the zone
	 * without rotation and translation
	 * @return
	 */
	public function calculateMotionData2D():MotionData2D {
		throw new Error("calculateMotionData2D() must be overridden in the subclasses");
	}

	/**
	 * Returns the area of the zone.
	 * Areas are used by the <code>CompositeZone</code> class to determine which area is bigger and deserves more weight.
	 * @return
	 */
	final public function getArea():Float {
		return area;
	}

	/**
	 * Sets the position of this zone.
	 */
	public function setPosition(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	/**
	 * Gets the position of this Deflector.
	 */
	public function getPosition():Point {
		position.setTo(x, y);
		return position;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Zone";
	}

	override public function getElementTypeXMLTag():Xml {
		// return Xml.parse("<zones/>");
		return Xml.createElement("zones");
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("rotation", Std.string(_rotation));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		rotation = Std.parseFloat(xml.get("rotation"));
	}
}
