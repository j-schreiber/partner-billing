public class Dispatcher {

    /** @Description    All handlers that will be executed in this transaction */
    @testVisible List<ITriggerHandler> activeHandlers;

    /** @Description
    *   Initializes the dispatcher without scope
    */
    public Dispatcher() {
        activeHandlers = new List<ITriggerHandler>();
    }

    /** @Description
    *   Initializes the dispatcher with the scope of the a SObject type and loads all handlers for this config
    *
    *   @param  sObjToken   Token for the SObject to be executed
    */
    public Dispatcher(Schema.SObjectType SObjToken) {
        activeHandlers = initHandlers([SELECT DeveloperName,Handler__c,Priority__c,SObject__c
                                       FROM HandlerControl__mdt
                                       WHERE SObject__r.QualifiedApiName = :SObjToken.getDescribe().getName() AND IsActive__c = true ORDER BY Priority__c DESC]);
    }

    /**
    *   @Description
    *   This method is called with a list of registered handler configs and tries to construct
    *   the triggerhandler implementations with dynamic type casting on run time and stores them in a cache
    *   If the initialization fails, the handler is skipped (but all other handlers still succeed)
    *
    *   @param  handlerControls     All handlers that are about to be executed
    *
    *   @return                     Ordered list of handlers (by priority) for this scope
    */
    public List<ITriggerHandler> initHandlers(List<HandlerControl__mdt> handlerControls) {
        List<ITriggerHandler> handlers = new List<ITriggerHandler>();
        for (HandlerControl__mdt hc : handlerControls) {
            try {
                ITriggerHandler triggerHandler = (ITriggerHandler)Type.forName(hc.Handler__c).newInstance(); 
                if (triggerHandler != null) handlers.add(triggerHandler);
            }
            catch (Exception e) { 
                System.debug(LoggingLevel.ERROR, 'Typecast failed for: ' + hc);
                System.debug(LoggingLevel.ERROR, 'Exception Type Name: ' + e.getTypeName());  
                System.debug(LoggingLevel.ERROR, 'Exception Message: ' + e.getMessage());
            }
        }
        return handlers;
    }

    /** @Description
    *   Executes all handlers in the prioritized order (higher priority is executed first)
    */
    public void executeHandlers() {
        for (ITriggerHandler handler : activeHandlers) handler.execute();
    }

}