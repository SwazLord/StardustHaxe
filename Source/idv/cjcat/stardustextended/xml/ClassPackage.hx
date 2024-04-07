package idv.cjcat.stardustextended.xml;

import openfl.Vector;

/**
 * An <code>XMLBuilder</code> object needs to know the mapping between an Xml tag's name and an actual class.
 * This class encapsulates multiple classes for the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
 * to register multiple classes (i.e. build the mapping relations).
 */
class ClassPackage {
	private var classes:Vector<Class<Dynamic>>;

	public function new() {
		classes = new Vector<Class<Dynamic>>();
		populateClasses();
	}

	/**
	 * Returns an array of classes.
	 * @return
	 */
	final public function getClasses():Vector<Class<Dynamic>> {
		return classes.concat();
	}

	/**
	 * [Abstract Method] Populates classes.
	 */
	private function populateClasses():Void {}
}
