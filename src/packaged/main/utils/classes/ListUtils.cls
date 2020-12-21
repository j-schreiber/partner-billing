public class ListUtils {

    public Enum SummarizeOperation {SUM}
    
    /** @Description
    *   Method summarizes data from a specific field of an in-memory SObject list. Methid currently
    *   only supports the SUM summarization function. 
    *
    *   @param  sos             SObjects that will be iterated
    *   @param  fieldToken      The field that will be summarized
    *   @param  summarizeOp     The summarization-operation (currently only supports SUM)
    *
    *   @return                 Summarization result (depending on operation)
    */
    public static Decimal summarizeSObjectListField(List<SObject> sos, Schema.SObjectField fieldToken, SummarizeOperation summarizeOp) {
        switch on summarizeOp {
            when SUM { return sumSObjectListField(sos, fieldToken); }
        }
        return null;
    }

    /** @Description
    *   Extracts data from an Id field and returns as Set.
    *
    *   @param  sos             SObjects that will be iterated
    *   @param  fieldToken      The field that will be extracted
    *
    *   @return                 All ids from the field to extract
    */
    public static Set<Id> extractIdsFromSObjectList(List<SObject> sos, Schema.SObjectField idField) {
        Set<Id> results = new Set<Id>();
        if (sos != null && !sos.isEmpty() && (sos[0].get(idField) instanceof Id)) {
            for (SObject so : sos) {
                results.add((Id)so.get(idField));
            }
        }
        return results;
    } 

    private static Decimal sumSObjectListField(List<SObject> sos, Schema.SObjectField fieldToken) {
        Decimal result = 0.0;
        if (sos != null && !sos.isEmpty() && (sos[0].get(fieldToken) instanceof Decimal)) {
            for (SObject so : sos) {
                result += (Decimal)so.get(fieldToken);
            }
        }
        return result;
    }
}
