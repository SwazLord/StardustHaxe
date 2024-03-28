package idv.cjcat.stardustextended.xml;

/**
 * An <code>XMLBuilder</code> object needs to know the mapping between an Xml tag's name and an actual class.
 * This class encapsulates multiple classes for the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
 * to register multiple classes (i.e. build the mapping relations).
 */
class ClassPackage {
	private var classes:Array<Class<Dynamic>>;

	public function new() {
		classes = new Array<Class<Dynamic>>();
		populateClasses();
	}

	/**
	 * Returns an array of classes.
	 * @return
	 */
	final public function getClasses():Array<Class<Dynamic>> {
		return classes.copy();
	}

	/**
	 * [Abstract Method] Populates classes.
	 */
	private function populateClasses():Void {}
}
