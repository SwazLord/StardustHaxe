package idv.cjcat.stardustextended;

import openfl.Vector;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * All Stardust elements are subclasses of this class.
 */
class StardustElement {
	private static var elementCounter:Map<String, Int> = new Map<String, Int>();

	public var name:String;

	public function new() {
		var str:String = getXMLTagName();
		var val:Int = elementCounter.get(str);

		if (val == null) {
			elementCounter.set(str, 0);
		} else {
			elementCounter.set(str, val++);
		}

		name = str + "_" + val;

		/* if (Reflect.field(elementCounter, str) == null) {
				Reflect.setField(elementCounter, str, 0);
			} else {
				Reflect.field(elementCounter, str) ++;
			}
			name = str + "_" + Reflect.field(elementCounter, str); */
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	/**
	 * [Abstract Method] Returns the related objects of the element.
	 *
	 * <p>
	 * This tells the <code>XMLBuilder</code> which elements are related,
	 * so the builder can include them in the Xml representation.
	 * </p>
	 * @return
	 */
	public function getRelatedObjects():Vector<StardustElement> {
		return new Vector<StardustElement>();
	}

	/**
	 * [Abstract Method] Returns the name of the root node of the element's Xml representation.
	 * @return
	 */
	public function getXMLTagName():String {
		return "StardustElement";
	}

	/**
	 * Returns the root tag of the Xml representation.
	 * @return
	 */
	final public function getXMLTag():Xml {
		/* var xml:Xml = Xml.parse("<" + getXMLTagName() + "/>");
			xml.set("name", name); */
		var xml:Xml = Xml.createElement(getXMLTagName());
		xml.set("name", name);
		return xml;
	}

	/**
	 * [Abstract Method] Returns the tag for containing elements of the same type.
	 * @return
	 */
	public function getElementTypeXMLTag():Xml {
		// return Xml.parse("<elements/>");
		return Xml.createElement("elements");
	}

	/**
	 * [Abstract Method] Generates Xml representation.
	 * @return
	 */
	public function toXML():Xml {
		return getXMLTag();
	}

	/**
	 * [Abstract Method] Reconstructs the element from Xml representations.
	 * @param    xml
	 * @param    builder
	 */
	public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {}

	/**
	 * This is called when the whole simulation's Xml parsing is complete
	 */
	public function onXMLInitComplete():Void {}
}
