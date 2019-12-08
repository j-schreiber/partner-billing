public with sharing class SObjectUtils {
    
    public static Set<String> getModifiedFields(SObject newRecord, SObject oldRecord) {
        Set<String> fields = new Set<String>();
        for (String fieldName : newRecord.getPopulatedFieldsAsMap().keySet()) {
            if (newRecord.getPopulatedFieldsAsMap().get(fieldName) != oldRecord.getPopulatedFieldsAsMap().get(fieldName)) {
                fields.add(fieldName);
            }
        }
        return fields;
    }

}
