// page 50210 "Detailed Cust Ledg Entry API"
// {
//     PageType = API;

//     SourceTable = "Detailed Cust. Ledg. Entry";

//     APIPublisher = 'metworld';
//     APIGroup = 'reports';
//     APIVersion = 'v1.0';

//     EntityName = 'detailedCustomerLedgerEntry';
//     EntitySetName = 'detailedCustomerLedgerEntries';

//     DelayedInsert = true;

//     ODataKeyFields = SystemId;

//     layout
//     {
//         area(Content)
//         {
//             field(id; Rec.SystemId)
//             {
//             }

//             field(entryNo; Rec."Entry No.")
//             {
//             }

//             field(custLedgerEntryNo; Rec."Cust. Ledger Entry No.")
//             {
//             }

//             field(postingDate; Rec."Posting Date")
//             {
//             }

//             field(entryType; Rec."Entry Type")
//             {
//             }

//             field(documentType; Rec."Document Type")
//             {
//             }

//             field(documentNo; Rec."Document No.")
//             {
//             }

//             field(customerNo; Rec."Customer No.")
//             {
//             }

//             field(currencyCode; Rec."Currency Code")
//             {
//             }

//             field(amount; Rec.Amount)
//             {
//             }

//             field(amountLCY; Rec."Amount (LCY)")
//             {
//             }

//             field(debitAmount; Rec."Debit Amount")
//             {
//             }

//             field(debitAmountLCY; Rec."Debit Amount (LCY)")
//             {
//             }

//             field(creditAmount; Rec."Credit Amount")
//             {
//             }

//             field(creditAmountLCY; Rec."Credit Amount (LCY)")
//             {
//             }

//             field(initialEntryDueDate; Rec."Initial Entry Due Date")
//             {
//             }
//         }
//     }
// }


page 50210 "Detailed Cust Ledg Entry API"
{
    PageType = API;

    SourceTable = "Detailed Cust. Ledg. Entry";

    APIPublisher = 'metworld';
    APIGroup = 'reports';
    APIVersion = 'v1.0';

    EntityName = 'detailedCustomerLedgerEntry';
    EntitySetName = 'detailedCustomerLedgerEntries';

    DelayedInsert = true;

    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field(id; Rec.SystemId)
            {
            }

            field(entryNo; Rec."Entry No.")
            {
            }

            field(custLedgerEntryNo; Rec."Cust. Ledger Entry No.")
            {
            }

            field(postingDate; Rec."Posting Date")
            {
            }

            field(entryType; Rec."Entry Type")
            {
            }

            field(documentType; Rec."Document Type")
            {
            }

            field(documentNo; Rec."Document No.")
            {
            }

            field(customerNo; Rec."Customer No.")
            {
            }

            field(currencyCode; Rec."Currency Code")
            {
            }

            field(amount; Rec.Amount)
            {
            }

            field(amountLCY; Rec."Amount (LCY)")
            {
            }

            field(debitAmount; Rec."Debit Amount")
            {
            }

            field(debitAmountLCY; Rec."Debit Amount (LCY)")
            {
            }

            field(creditAmount; Rec."Credit Amount")
            {
            }

            field(creditAmountLCY; Rec."Credit Amount (LCY)")
            {
            }

            field(initialEntryDueDate; Rec."Initial Entry Due Date")
            {
            }

            // -------------------------------------------------
            // APPLICATION / HISTORICAL AGING FIELDS
            // -------------------------------------------------

            field(appliedCustLedgerEntryNo; Rec."Applied Cust. Ledger Entry No.")
            {
            }

            field(unapplied; Rec.Unapplied)
            {
            }

            field(unappliedByEntryNo; Rec."Unapplied by Entry No.")
            {
            }

            field(applicationNo; Rec."Application No.")
            {
            }

            field(ledgerEntryAmount; Rec."Ledger Entry Amount")
            {
            }

            field(initialDocumentType; Rec."Initial Document Type")
            {
            }

            field(remainingPmtDiscPossible; Rec."Remaining Pmt. Disc. Possible")
            {
            }

            // -------------------------------------------------
            // ADDITIONAL CONTROL / AUDIT FIELDS
            // -------------------------------------------------

            field(userId; Rec."User ID")
            {
            }

            field(sourceCode; Rec."Source Code")
            {
            }

            field(transactionNo; Rec."Transaction No.")
            {
            }

            field(reasonCode; Rec."Reason Code")
            {
            }

            field(postingGroup; Rec."Posting Group")
            {
            }
        }
    }
}