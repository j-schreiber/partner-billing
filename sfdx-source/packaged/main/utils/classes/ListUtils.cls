public class ListUtils {

    public Enum SummarizeOperation {SUM}
    
    public static Decimal summarizeSObjectListField(List<SObject> sos, Schema.SObjectField fieldToken, SummarizeOperation summarizeOp) {
        switch on summarizeOp {
            when SUM { return sumSObjectListField(sos, fieldToken); }
        }
        return null;
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
