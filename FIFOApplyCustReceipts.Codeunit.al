codeunit 50205 "FIFOApplyCustReceipts"
{
    procedure ApplyReceiptFIFO(ReceiptDocNo: Code[20])
    var
        ReceiptCustLedgEntry: Record "Cust. Ledger Entry";
        InvoiceCustLedgEntry: Record "Cust. Ledger Entry";
        ApplyCustEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        ReceiptRemainingAmount: Decimal;
        InvoiceRemainingAmount: Decimal;
        AmountToApply: Decimal;
        OriginalReceiptEntryNo: Integer;
        CustomerNo: Code[20];
        AppliedSomething: Boolean;
    begin
        // ---------------------------------------------------------
        // 1. Find the selected open payment
        // ---------------------------------------------------------
        ReceiptCustLedgEntry.Reset();

        ReceiptCustLedgEntry.SetRange(
            "Document Type",
            ReceiptCustLedgEntry."Document Type"::Payment);

        ReceiptCustLedgEntry.SetRange(
            "Document No.",
            ReceiptDocNo);

        ReceiptCustLedgEntry.SetRange(
            Open,
            true);

        if not ReceiptCustLedgEntry.FindFirst() then
            Error(
                'Open payment %1 was not found.',
                ReceiptDocNo);

        OriginalReceiptEntryNo :=
            ReceiptCustLedgEntry."Entry No.";

        CustomerNo :=
            ReceiptCustLedgEntry."Customer No.";

        // ---------------------------------------------------------
        // 2. Get remaining payment amount
        // ---------------------------------------------------------
        ReceiptCustLedgEntry.CalcFields(
            "Remaining Amount");

        ReceiptRemainingAmount :=
            Abs(ReceiptCustLedgEntry."Remaining Amount");

        if ReceiptRemainingAmount <= 0 then
            Error(
                'Payment %1 has no remaining amount to apply.',
                ReceiptDocNo);

        // ---------------------------------------------------------
        // 3. Find customer's open invoices
        // ---------------------------------------------------------
        InvoiceCustLedgEntry.Reset();

        InvoiceCustLedgEntry.SetCurrentKey(
            "Customer No.",
            "Posting Date",
            "Entry No.");

        InvoiceCustLedgEntry.SetRange(
            "Customer No.",
            CustomerNo);

        InvoiceCustLedgEntry.SetRange(
            "Document Type",
            InvoiceCustLedgEntry."Document Type"::Invoice);

        InvoiceCustLedgEntry.SetRange(
            Open,
            true);

        InvoiceCustLedgEntry.SetAscending(
            "Posting Date",
            true);

        // ---------------------------------------------------------
        // 4. Loop through invoices oldest first
        // ---------------------------------------------------------
        if InvoiceCustLedgEntry.FindSet(true) then begin
            repeat
                InvoiceCustLedgEntry.CalcFields(
                    "Remaining Amount");

                InvoiceRemainingAmount :=
                    Abs(InvoiceCustLedgEntry."Remaining Amount");

                if InvoiceRemainingAmount > 0 then begin

                    // -------------------------------------------------
                    // Calculate application amount
                    // -------------------------------------------------
                    if ReceiptRemainingAmount >= InvoiceRemainingAmount then
                        AmountToApply := InvoiceRemainingAmount
                    else
                        AmountToApply := ReceiptRemainingAmount;

                    if AmountToApply > 0 then begin

                        // -------------------------------------------------
                        // Refresh payment
                        // -------------------------------------------------
                        ReceiptCustLedgEntry.Get(
                            OriginalReceiptEntryNo);

                        ReceiptCustLedgEntry.CalcFields(
                            "Remaining Amount");

                        ReceiptRemainingAmount :=
                            Abs(ReceiptCustLedgEntry."Remaining Amount");

                        if ReceiptRemainingAmount <= 0 then
                            exit;

                        if AmountToApply > ReceiptRemainingAmount then
                            AmountToApply :=
                                ReceiptRemainingAmount;

                        // -------------------------------------------------
                        // Clear previous application parameters
                        // -------------------------------------------------
                        Clear(ApplyUnapplyParameters);

                        // -------------------------------------------------
                        // Set receipt as applying entry
                        // -------------------------------------------------
                        ReceiptCustLedgEntry."Applying Entry" := true;

                        ReceiptCustLedgEntry."Applies-to ID" :=
                            ReceiptCustLedgEntry."Document No.";

                        ReceiptCustLedgEntry.Modify();

                        // -------------------------------------------------
                        // Set invoice application amount
                        // -------------------------------------------------
                        InvoiceCustLedgEntry."Amount to Apply" :=
                            AmountToApply;

                        InvoiceCustLedgEntry."Applies-to ID" :=
                            ReceiptCustLedgEntry."Document No.";

                        InvoiceCustLedgEntry.Modify();

                        // -------------------------------------------------
                        // Apply using the standard BC application engine
                        // -------------------------------------------------
                        ApplyCustEntries.Apply(
                            ReceiptCustLedgEntry,
                            ApplyUnapplyParameters);

                        AppliedSomething := true;

                        // -------------------------------------------------
                        // Refresh payment
                        // -------------------------------------------------
                        ReceiptCustLedgEntry.Get(
                            OriginalReceiptEntryNo);

                        ReceiptCustLedgEntry.CalcFields(
                            "Remaining Amount");

                        ReceiptRemainingAmount :=
                            Abs(
                                ReceiptCustLedgEntry."Remaining Amount");
                    end;
                end;

            until
                (InvoiceCustLedgEntry.Next() = 0) or
                (ReceiptRemainingAmount <= 0);
        end;

        // ---------------------------------------------------------
        // 5. Check result
        // ---------------------------------------------------------
        if not AppliedSomething then
            Error(
                'No open invoices were found for customer %1.',
                CustomerNo);

        Message(
            'Payment %1 has been processed using FIFO.',
            ReceiptDocNo);
    end;
}