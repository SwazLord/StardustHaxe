package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Zone with no thickness.
 */
class Contour extends Zone {
	public var virtualThickness(get, set):Float;

	private var _virtualThickness:Float;

	public function new() {
		super();
		_virtualThickness = 1;
	}

	/**
	 * Used to calculate "virtual area" for the <code>CompositeZone</code> class,
	 * since contours have zero thickness.
	 * The larger the virtual thickness, the larger the virtual area.
	 */
	final private function get_virtualThickness():Float {
		return _virtualThickness;
	}

	final private function set_virtualThickness(value:Float):Float {
		_virtualThickness = value;
		updateArea();
		return value;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Contour";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("virtualThickness", Std.string(virtualThickness));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("virtualThickness")) {
			virtualThickness = Std.parseFloat(xml.get("virtualThickness"));
		}
	}
}
