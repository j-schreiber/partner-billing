@isTest
public class T_Dispatcher {
    
    /**************************************************************************************
    *                                       DISPATCHER
    *   The tests don't test functionality but provide code coverage and verify that any configurations
    *   registered for the framework (by dependend packages) do not break standard functionality
    *   Actual testing of functionality is expected by the implementing package that registers the handler
    /**************************************************************************************/

    @isTest
    static void init_NoScope_NoActiveHandlers() {
        // SETUP
        Dispatcher d = new Dispatcher();
        // VERIFY
        System.assertEquals(0, d.activeHandlers.size(), 'activeHandlers.size()');
    }

    @isTest
    static void initHandlers_ValidConfig_HandlerInitialized() {
        // SETUP
        HandlerControl__mdt testConfig = new HandlerControl__mdt(SObject__c = 'Account',
                                                                 DeveloperName = 'TEST_HANDLER_CONFIG',
                                                                 IsActive__c = true,
                                                                 Priority__c = 0,
                                                                 Handler__c = 'T_Dispatcher.TestTriggerHandler');
        // ACTION
        List<ITriggerHandler> handlers = new Dispatcher().initHandlers(new List<HandlerControl__mdt>{testConfig});
        // VERIFY
        System.assertEquals(1, handlers.size(), 'handlers.size()');
    }

    @isTest
    static void initHandlers_InvalidConfig_NoHandlerInitialized() {
        // SETUP
        HandlerControl__mdt testConfig = new HandlerControl__mdt(SObject__c = 'Account',
                                                                 DeveloperName = 'TEST_HANDLER_CONFIG',
                                                                 IsActive__c = true,
                                                                 Priority__c = 0,
                                                                 Handler__c = 'T_Dispatcher.InvalidHandlerName');
        // ACTION
        List<ITriggerHandler> handlers = new Dispatcher().initHandlers(new List<HandlerControl__mdt>{testConfig});
        // VERIFY
        System.assertEquals(0, handlers.size(), 'handlers.size()');
    }

    @isTest
    static void executeHandlers_Account_AllHandlersExecuted() {
        // SETUP
        Dispatcher sObjDispatcher = new Dispatcher(Account.getSObjectType());
        // ACTION
        sObjDispatcher.executeHandlers();
        // VERIFY
        System.assertEquals(
            [SELECT COUNT() FROM HandlerControl__mdt WHERE SObject__r.QualifiedApiName = 'Account' AND IsActive__c = true], 
            sObjDispatcher.activeHandlers.size(), 
            'activeHandlers.size()'
        );
    }

    @isTest
    static void executeHandlers_TimeEntry_AllHandlersExecuted(){
        // SETUP
        Dispatcher sObjDispatcher = new Dispatcher(TimeEntry__c.getSObjectType());
        // ACTION
        sObjDispatcher.executeHandlers();
        // VERIFY
        System.assertEquals(
            [SELECT COUNT() FROM HandlerControl__mdt WHERE SObject__r.QualifiedApiName = 'TimeEntry__c' AND IsActive__c = true], 
            sObjDispatcher.activeHandlers.size(), 
            'activeHandlers.size()'
        );    
    }

    @isTest
    static void executeHandlers_Budget_AllHandlersExecuted(){
        // SETUP
        Dispatcher sObjDispatcher = new Dispatcher(Budget__c.getSObjectType());
        // ACTION
        sObjDispatcher.executeHandlers();
        // VERIFY
        System.assertEquals(
            [SELECT COUNT() FROM HandlerControl__mdt WHERE SObject__r.QualifiedApiName = 'Budget__c' AND IsActive__c = true], 
            sObjDispatcher.activeHandlers.size(), 
            'activeHandlers.size()'
        );    
    }

    public class TestTriggerHandler implements ITriggerHandler {
        public void execute() { }
    }
}