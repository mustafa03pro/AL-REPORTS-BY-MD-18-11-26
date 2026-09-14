pageextension 50206 "CustLedgerEntriesExt" extends "Customer Ledger Entries"
{
    actions
    {
        addlast(processing)
        {
            action(ApplyReceiptFIFOAction)
            {
                ApplicationArea = All;

                Caption = 'Auto-Apply FIFO Receipt';

                ToolTip =
                    'Automatically applies the selected customer receipt to outstanding invoices from oldest to newest.';

                Image = ApplyEntries;

                Enabled =
                    Rec.Open
                    and
                    (Rec."Document Type" =
                        Rec."Document Type"::Payment);

                trigger OnAction()
                var
                    FIFOApply: Codeunit "FIFOApplyCustReceipts";
                    ReceiptDocumentNo: Code[20];
                    ConfirmApplication: Boolean;
                begin
                    // Check that selected entry is open
                    Rec.TestField(Open, true);

                    // Check that selected entry is a payment
                    Rec.TestField(
                        "Document Type",
                        Rec."Document Type"::Payment);

                    ReceiptDocumentNo :=
                        Rec."Document No.";

                    // Ask user for confirmation
                    ConfirmApplication :=
                        Confirm(
                            'Do you want to automatically apply payment %1 to the customer invoices using FIFO?',
                            false,
                            ReceiptDocumentNo);

                    if not ConfirmApplication then
                        exit;

                    // Run FIFO application
                    FIFOApply.ApplyReceiptFIFO(
                        ReceiptDocumentNo);

                    // Refresh page
                    CurrPage.Update(false);
                end;
            }
        }
    }
}