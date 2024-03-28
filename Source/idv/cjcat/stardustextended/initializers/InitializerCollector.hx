package idv.cjcat.stardustextended.initializers;


interface InitializerCollector
{

    
    function addInitializer(initializer : Initializer) : Void
    ;
    
    function removeInitializer(initializer : Initializer) : Void
    ;
    
    function clearInitializers() : Void
    ;
}
