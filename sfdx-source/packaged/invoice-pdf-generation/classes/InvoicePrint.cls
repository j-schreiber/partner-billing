public class InvoicePrint extends Invoice {

    public String TotalTaxesFormatted {
        public get {
            TotalTaxesFormatted = TotalTaxes.format() + ' €';
            return TotalTaxesFormatted;
        }
        private set;
    }

    public InvoicePrint(Id recordId) {
        super(recordId);
    }
}
