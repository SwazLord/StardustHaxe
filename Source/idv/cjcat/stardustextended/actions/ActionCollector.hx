package idv.cjcat.stardustextended.actions;


interface ActionCollector
{

    
    function addAction(action : Action) : Void
    ;
    
    function removeAction(action : Action) : Void
    ;
    
    function clearActions() : Void
    ;
}

