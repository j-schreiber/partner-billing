({
    refreshView : function(component, event, helper) {
        console.log('Refreshing View ...');
        $A.get('e.force:refreshView').fire();
    }
})
