package idv.cjcat.stardustextended.xml;

import starling.assets.XmlFactory;
import openfl.Vector;
import openfl.errors.TypeError;
import openfl.errors.IllegalOperationError;
import openfl.errors.Error;
import haxe.ds.Map;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.Stardust;

/**
 * <code>XMLBuilder</code> can generate Stardust elements' Xml representations and reconstruct elements from existing Xml data.
 *
 * <p>
 * Every <code>StardustElement</code> objects can generate its Xml representation through the <code>StardustElement.toXML()</code> method.
 * And they can reconstruct configurations from existing Xml data through the <code>StardustElement.parseXML()</code> method.
 * </p>
 */
class XMLBuilder {
	// Xml building
	//------------------------------------------------------------------------------------------------

	/**
	 * Generate the Xml representation of an Stardust element.
	 *
	 * <p>
	 * All related elements' would be included in the Xml representation.
	 * </p>
	 * @param    rootElement
	 * @return
	 */
	public static function buildXML(rootElement:StardustElement):Xml {
		// final var root:Xml = <StardustParticleSystem/>;
		// root.att.version = Stardust.VERSION.toString();
		final root:Xml = Xml.parse('<StardustParticleSystem />').firstElement();
		root.set("version", Std.string(Stardust.VERSION));

		final relatedElements:Map<String, StardustElement> = new Map<String, StardustElement>();
		traverseRelatedObjects(rootElement, relatedElements);

		var relatedElementsArray:Vector<StardustElement> = new Vector<StardustElement>();
		var element:StardustElement;
		for (element in relatedElements) {
			relatedElementsArray.push(element);
		}
		relatedElementsArray.sort(elementTypeSorter);

		var root_access = new haxe.xml.Access(root);

		for (element in relatedElementsArray) {
			var elementXML:Xml = element.toXML();
			var typeXML:Xml = element.getElementTypeXMLTag();

			if (!root_access.hasNode.resolve(typeXML.nodeName)) {
				root_access.x.addChild(typeXML);
			}

			root_access.node.resolve(typeXML.nodeName).x.addChild(elementXML);

			/* if (root[typeXML.name()].length() == 0)
					root.appendChild(typeXML);
				root[typeXML.name()].appendChild(elementXML); */
		}

		return root;
	}

	private static function elementTypeSorter(e1:StardustElement, e2:StardustElement):Int {
		if (e1.getXMLTagName() > e2.getXMLTagName())
			return 1;
		else if (e1.getXMLTagName() < e2.getXMLTagName())
			return -1;
		if (e1.name > e2.name)
			return 1;
		return -1;
	}

	private static function traverseRelatedObjects(element:StardustElement, relatedElements:Map<String, StardustElement>):Void {
		if (element == null)
			return;

		if (relatedElements[element.name] != null) {
			if (relatedElements[element.name] != element) {
				throw new Error("Duplicate element name: " + element.name + " " + relatedElements[element.name]);
			}
		} else {
			relatedElements[element.name] = element;
		}
		for (e in element.getRelatedObjects()) {
			traverseRelatedObjects(e, relatedElements);
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of Xml building
	private var elementClasses:Map<String, Class<Dynamic>>;
	private var elements:Map<String, StardustElement>;

	public function new() {
		elementClasses = new Map<String, Class<Dynamic>>();
		elements = new Map<String, StardustElement>();
	}

	/**
	 * To use <code>XMLBuilder</code> with your custom subclasses of Stardust elements,
	 * you must register your class and Xml tag name first.
	 *
	 * <p>
	 * For example, if you register the <code>MyAction</code> class with Xml tag name "HelloWorld",
	 * <code>XMLBuilder</code> knows you are referring to the <code>MyAction</code> class when a &ltHelloWorld&gt tag
	 * appears in the Xml representation.
	 * </p>
	 * @param    elementClass
	 */
	public function registerClass(elementClass:Class<Dynamic>):Void {
		var element:StardustElement = cast(Type.createInstance(elementClass, []), StardustElement);
		if (element == null) {
			throw new IllegalOperationError(elementClass + " is not a subclass of the StardustElement class.");
		}
		var tagName:String = element.getXMLTagName();
		if (elementClasses[tagName] != null) {
			throw new IllegalOperationError("This element class name is already registered: " + element.getXMLTagName());
		}
		elementClasses[tagName] = elementClass;
	}

	/**
	 * Registers multiple classes.
	 * @param    classes
	 */
	public function registerClasses(classes:Vector<Class<Dynamic>>):Void {
		for (c in classes) {
			registerClass(c);
		}
	}

	/**
	 * Registers multiple classes from a <code>ClassPackage</code> object.
	 * @param    classPackage
	 */
	public function registerClassesFromClassPackage(classPackage:ClassPackage):Void {
		registerClasses(classPackage.getClasses());
	}

	/**
	 * Undos the Xml tag name registration.
	 * @param    name
	 */
	public function unregisterClass(name:String):Void {
		// delete elementClasses[name];
		elementClasses.remove(name);
	}

	/**
	 * After reconstructing elements through the <code>buildFromXML()</code> method,
	 * reconstructed elements can be extracted through this method.
	 *
	 * <p>
	 * Each Stardust element has a name; this name is used to identify elements.
	 * </p>
	 * @param name
	 * @return
	 */
	public function getElementByName(name:String):StardustElement {
		if (elements[name] == null) {
			throw new IllegalOperationError("Element not found: " + name);
		}
		return elements[name];
	}

	public function getElementsByClass(cl:Class<Dynamic>):Vector<StardustElement> {
		var ret:Vector<StardustElement> = new Vector<StardustElement>();
		for (key in elements.keys()) {
			if (Std.isOfType(elements.get(key), cl)) {
				ret.push(elements[key]);
			}
		}
		return ret;
	}

	/**
	 * Reconstructs elements from Xml representations.
	 *
	 * <p>
	 * After calling this method, you may extract constructed elements through the <code>getElementByName()</code> method.
	 * </p>
	 * @param    xml
	 */
	public function buildFromXML(xml:Xml):Void {
		var firstElement:Xml = xml.firstElement();
		elements = new Map<String, StardustElement>();
		var element:StardustElement;
		for (tag in firstElement.elements()) {
			for (node in tag.elements()) {

				//trace("node => " + node.elements());
					try {
						//trace("node name = " + node.nodeName);
						var NodeClass:Class<Dynamic> = elementClasses[node.nodeName];
						element = cast(Type.createInstance(NodeClass, []), StardustElement);
					} catch (err:TypeError) {
						throw new Error("Unable to instantiate class "
							+ node.get("name")
							+ ". Perhaps you forgot to "
							+ "call XMLBuilder.registerClass for this type? Original error: "
							+ err.toString());
				}
				if (elements[node.get("name")] != null) {
					throw new Error("Duplicate element name: " + node.get("name") + " " + element.name);
				}
				elements[node.get("name")] = element;
			}
		}

		for (tag in firstElement.elements()) {
			for (node in tag.elements()) {
				element = cast(elements[node.get("name")], StardustElement);
				element.parseXML(node, this);
			}
		}

		for (stardustElement in elements) {
			stardustElement.onXMLInitComplete();
		}
	}
}
