import { LightningElement, track } from 'lwc';

export default class invoicingCanvas extends LightningElement {

    @track processStage = 1;

    get processIndicatorStage() {
        return this.processStage.toString();
    }

    get displayTimeEntrySelection() {
        return this.processStage === 1;
    }

    get displayInvoicesPreview() {
        return this.processStage === 2;
    }

    get displayInvoicesPdfCreation() {
        return this.processStage === 3;
    }

    get displayInvoicesPdfSend() {
        return this.processStage === 4;
    }

    increaseProcessStage() {
        if (this.processStage < 4) this.processStage++;
    }

    decreaseProcessStage() {
        if (this.processStage > 1) this.processStage--;
    }

}