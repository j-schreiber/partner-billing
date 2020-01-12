import { LightningElement, api } from 'lwc';

import NUMBER from '@salesforce/label/c.Generic_Word_Number';
import CATEGORY from '@salesforce/label/c.Generic_Word_Category';
import BUDGET from '@salesforce/label/c.Generic_Word_Budget';
import CONSULTANT from '@salesforce/label/c.Generic_Word_Consultant';
import DATE from '@salesforce/label/c.Generic_Word_Date';
import DURATION from '@salesforce/label/c.Generic_Word_Duration';
import DESCRIPTION from '@salesforce/label/c.Generic_Word_Description';
import ACTIONS from '@salesforce/label/c.Generic_Word_Actions';

export default class TimeEntryApprovalDataTable extends LightningElement {
    @api timeEntries;

    LABELS = {
        NUMBER,
        CATEGORY,
        BUDGET,
        CONSULTANT,
        DATE,
        DURATION,
        DESCRIPTION,
        ACTIONS
    }
}