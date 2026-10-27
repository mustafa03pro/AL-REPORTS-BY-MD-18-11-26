// page 50204 "Direct Consumption Scanner"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = Tasks;
//     Caption = 'Direct Consumption Scanner';

//     layout
//     {
//         area(content)
//         {
//             group(ScanGroup)
//             {
//                 Caption = 'Barcode Scanner Input';

//                 field(ScannedBarcode; ScannedBarcode)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Scan Barcode / GTIN';
//                     ToolTip = 'Scan or type GTIN/Barcode and press Enter.';
//                     QuickEntry = true;

//                     trigger OnValidate()
//                     begin
//                         if ScannedBarcode <> '' then begin
//                             ProcessConsumption(ScannedBarcode);
//                             ScannedBarcode := '';
//                             CurrPage.Update(false);
//                         end;
//                     end;
//                 }
//                 field(SelectedLocation; SelectedLocation)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Location Code';
//                     TableRelation = Location;
//                     ToolTip = 'Select the warehouse/store location to adjust stock from.';
//                 }
//                 field(DefaultQty; DefaultQty)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Quantity per Scan';
//                     ToolTip = 'Default quantity to reduce per barcode scan.';
//                 }
//             }
//             group(LastScanInfo)
//             {
//                 Caption = 'Last Scanned Item Details';

//                 field(LastItemNo; LastItemNo)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Item No.';
//                     Editable = false;
//                 }
//                 field(LastItemDesc; LastItemDesc)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Description';
//                     Editable = false;
//                 }
//                 field(LastQty; LastQty)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Reduced Qty';
//                     Editable = false;
//                 }
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         DefaultQty := 1;
//     end;

//     var
//         ScannedBarcode: Code[50];
//         SelectedLocation: Code[10];
//         DefaultQty: Decimal;
//         LastItemNo: Code[20];
//         LastItemDesc: Text[100];
//         LastQty: Decimal;

//     // local procedure ProcessConsumption(Barcode: Code[50])
//     // var
//     //     Item: Record Item;
//     //     ItemRef: Record "Item Reference";
//     //     ItemJnlLine: Record "Item Journal Line";
//     //     ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
//     //     ItemNo: Code[20];
//     //     TemplateName: Code[10];
//     //     BatchName: Code[10];
//     //     NextLineNo: Integer;
//     //     DocNo: Code[20];
//     // begin
//     //     TemplateName := 'ITEM';
//     //     BatchName := 'DEFAULT';
//     //     ItemNo := '';

//     //     // 1. Resolve Barcode / GTIN to Item No.
//     //     ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
//     //     ItemRef.SetRange("Reference No.", Barcode);
//     //     if ItemRef.FindFirst() then
//     //         ItemNo := ItemRef."Item No."
//     //     else begin
//     //         Item.SetRange(GTIN, Barcode);
//     //         if Item.FindFirst() then
//     //             ItemNo := Item."No."
//     //         else
//     //             if Item.Get(Barcode) then
//     //                 ItemNo := Item."No.";
//     //     end;

//     //     if ItemNo = '' then
//     //         Error('No item found matching Barcode/GTIN: %1', Barcode);

//     //     // 2. Validate Item Type
//     //     Item.Get(ItemNo);
//     //     if Item.Type <> Item.Type::Inventory then
//     //         Error('Item %1 must be set to Type = Inventory.', ItemNo);

//     //     // 3. Determine Line No and Generate Document No
//     //     ItemJnlLine.SetRange("Journal Template Name", TemplateName);
//     //     ItemJnlLine.SetRange("Journal Batch Name", BatchName);
//     //     if ItemJnlLine.FindLast() then
//     //         NextLineNo := ItemJnlLine."Line No." + 10000
//     //     else
//     //         NextLineNo := 10000;

//     //     DocNo := 'SCAN' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>');

//     //     // 4. Populate and Insert Item Journal Line
//     //     ItemJnlLine.Init();
//     //     ItemJnlLine."Journal Template Name" := TemplateName;
//     //     ItemJnlLine."Journal Batch Name" := BatchName;
//     //     ItemJnlLine."Line No." := NextLineNo;
//     //     ItemJnlLine."Posting Date" := WorkDate();
//     //     ItemJnlLine."Document Date" := WorkDate();
//     //     ItemJnlLine."Document No." := DocNo;
//     //     ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";

//     //     ItemJnlLine.Validate("Item No.", ItemNo);

//     //     if SelectedLocation <> '' then
//     //         ItemJnlLine.Validate("Location Code", SelectedLocation);

//     //     ItemJnlLine.Validate(Quantity, DefaultQty);
//     //     ItemJnlLine.Insert(true);

//     //     // 5. Direct Post Line cleanly
//     //     ItemJnlPostLine.RunWithCheck(ItemJnlLine);

//     //     // 6. Clean up temporary journal entry
//     //     if ItemJnlLine.Get(TemplateName, BatchName, NextLineNo) then
//     //         ItemJnlLine.Delete();

//     //     // 7. Update UI
//     //     LastItemNo := Item."No.";
//     //     LastItemDesc := Item.Description;
//     //     LastQty := DefaultQty;
//     // end;

//     local procedure ProcessConsumption(Barcode: Code[50])
//     var
//         Item: Record Item;
//         ItemRef: Record "Item Reference";
//         ItemJnlLine: Record "Item Journal Line";
//         ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
//         ItemNo: Code[20];
//         TemplateName: Code[10];
//         BatchName: Code[10];
//         NextLineNo: Integer;
//         DocNo: Code[20];
//         AvailQty: Decimal;
//     begin
//         // FIX 1: Enforce Location Code selection
//         if SelectedLocation = '' then
//             Error('Please select a Location Code before scanning.');

//         TemplateName := 'ITEM';
//         BatchName := 'DEFAULT';
//         ItemNo := '';

//         // 1. Resolve Barcode / GTIN to Item No.
//         ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
//         ItemRef.SetRange("Reference No.", Barcode);
//         if ItemRef.FindFirst() then
//             ItemNo := ItemRef."Item No."
//         else begin
//             Item.SetRange(GTIN, Barcode);
//             if Item.FindFirst() then
//                 ItemNo := Item."No."
//             else
//                 if Item.Get(Barcode) then
//                     ItemNo := Item."No.";
//         end;

//         if ItemNo = '' then
//             Error('No item found matching Barcode/GTIN: %1', Barcode);

//         // 2. Validate Item Type & Prevent Negative Stock Posting
//         Item.Get(ItemNo);
//         if Item.Type <> Item.Type::Inventory then
//             Error('Item %1 must be set to Type = Inventory.', ItemNo);

//         // FIX 2: Check current stock on the chosen location to prevent open negative entries
//         Item.SetRange("Location Filter", SelectedLocation);
//         Item.CalcFields(Inventory);
//         if Item.Inventory < DefaultQty then
//             Error('Insufficient stock for Item %1 at Location %2. Available: %3, Required: %4.',
//                   ItemNo, SelectedLocation, Item.Inventory, DefaultQty);

//         // 3. Determine Line No and Generate Document No
//         ItemJnlLine.SetRange("Journal Template Name", TemplateName);
//         ItemJnlLine.SetRange("Journal Batch Name", BatchName);
//         if ItemJnlLine.FindLast() then
//             NextLineNo := ItemJnlLine."Line No." + 10000
//         else
//             NextLineNo := 10000;

//         DocNo := 'SCAN' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>');

//         // 4. Populate and Insert Item Journal Line
//         ItemJnlLine.Init();
//         ItemJnlLine."Journal Template Name" := TemplateName;
//         ItemJnlLine."Journal Batch Name" := BatchName;
//         ItemJnlLine."Line No." := NextLineNo;
//         ItemJnlLine."Posting Date" := WorkDate();
//         ItemJnlLine."Document Date" := WorkDate();
//         ItemJnlLine."Document No." := DocNo;
//         ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";

//         ItemJnlLine.Validate("Item No.", ItemNo);
//         ItemJnlLine.Validate("Location Code", SelectedLocation);
//         ItemJnlLine.Validate(Quantity, DefaultQty);
//         ItemJnlLine.Insert(true);

//         // 5. Direct Post Line cleanly
//         ItemJnlPostLine.RunWithCheck(ItemJnlLine);

//         // 6. Clean up temporary journal entry
//         if ItemJnlLine.Get(TemplateName, BatchName, NextLineNo) then
//             ItemJnlLine.Delete();

//         // 7. Update UI
//         LastItemNo := Item."No.";
//         LastItemDesc := Item.Description;
//         LastQty := DefaultQty;
//     end;
// }

page 50204 "Direct Consumption Scanner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Direct Consumption Scanner';

    layout
    {
        area(content)
        {
            group(ScanGroup)
            {
                Caption = 'Barcode Scanner Input';

                field(PostingDate; PostingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    trigger OnValidate()
                    begin
                        if PostingDate = 0D then
                            Error('Posting Date is required.');
                    end;
                }
                field(SelectedLocation; SelectedLocation)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location.Code;
                    trigger OnValidate()
                    begin
                        if SelectedLocation = '' then
                            Error('Location Code is mandatory.');
                        TempScanLine.Reset();
                        if not TempScanLine.IsEmpty() then begin
                            TempScanLine.DeleteAll();
                            CurrPage.ScanLines.Page.SetBuffer(TempScanLine);
                            Message('Pending lines were cleared because the location changed.');
                        end;
                    end;
                }
                field(ScannedBarcode; ScannedBarcode)
                {
                    ApplicationArea = All;
                    Caption = 'Scan Barcode / GTIN';
                    ToolTip = 'Scan or type a GTIN/barcode and press Enter to add the item.';
                    QuickEntry = true;
                    trigger OnValidate()
                    begin
                        if ScannedBarcode <> '' then begin
                            AddScannedItem(ScannedBarcode);
                            Clear(ScannedBarcode);
                            CurrPage.ScanLines.Page.SetBuffer(TempScanLine);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(DefaultQty; DefaultQty)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity per Scan';
                    DecimalPlaces = 0 : 5;
                    trigger OnValidate()
                    begin
                        if DefaultQty <= 0 then
                            Error('Quantity per scan must be greater than zero.');
                    end;
                }
            }

            part(ScanLines; "Direct Consumption Scan Lines")
            {
                ApplicationArea = All;
                Caption = 'Scanned Consumption Items';
            }

            group(LastScanInfo)
            {
                Caption = 'Last Scanned Item Details';
                field(LastItemNo; LastItemNo) { ApplicationArea = All; Editable = false; }
                field(LastItemDesc; LastItemDesc) { ApplicationArea = All; Editable = false; }
                field(LastQty; LastQty) { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PreviewPosting)
            {
                ApplicationArea = All;
                Caption = 'Preview Posting';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PreviewPage: Page "Direct Consumption Preview";
                begin
                    ValidateBeforePosting();
                    PreviewPage.SetBuffer(TempScanLine);
                    PreviewPage.RunModal();
                end;
            }
            action(PostConsumption)
            {
                ApplicationArea = All;
                Caption = 'Post Consumption';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    PostPendingConsumption();
                end;
            }
            action(DeleteAllLines)
            {
                ApplicationArea = All;
                Caption = 'Delete All Lines';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    if TempScanLine.IsEmpty() then
                        exit;
                    if Confirm('Delete all pending consumption lines?', false) then begin
                        TempScanLine.Reset();
                        TempScanLine.DeleteAll();
                        CurrPage.ScanLines.Page.SetBuffer(TempScanLine);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        DefaultQty := 1;
        PostingDate := WorkDate();
        CurrPage.ScanLines.Page.SetBuffer(TempScanLine);
    end;

    var
        ScannedBarcode: Code[50];
        SelectedLocation: Code[10];
        PostingDate: Date;
        DefaultQty: Decimal;
        LastItemNo: Code[20];
        LastItemDesc: Text[100];
        LastQty: Decimal;
        TempScanLine: Record "Direct Consumption Scan Line" temporary;

    local procedure AddScannedItem(BarcodeValue: Code[50])
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemNo: Code[20];
        AvailableQty: Decimal;
        RequestedQty: Decimal;
        NextEntryNo: Integer;
    begin
        if PostingDate = 0D then
            Error('Select a Posting Date before scanning.');
        if SelectedLocation = '' then
            Error('Select a Location Code before scanning.');
        if DefaultQty <= 0 then
            Error('Quantity per scan must be greater than zero.');

        ItemNo := '';
        ItemRef.Reset();
        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        ItemRef.SetRange("Reference No.", BarcodeValue);
        if ItemRef.FindFirst() then
            ItemNo := ItemRef."Item No."
        else begin
            Item.Reset();
            if StrLen(BarcodeValue) <= MaxStrLen(Item.GTIN) then begin
                Item.SetRange(GTIN, BarcodeValue);
                if Item.FindFirst() then
                    ItemNo := Item."No.";
            end;
            if ItemNo = '' then
                if Item.Get(BarcodeValue) then
                    ItemNo := Item."No.";
        end;

        if ItemNo = '' then
            Error('No item found matching Barcode/GTIN: %1', BarcodeValue);
        Item.Get(ItemNo);
        if Item.Type <> Item.Type::Inventory then
            Error('Item %1 must be set to Type = Inventory.', ItemNo);
        if Item.Blocked then
            Error('Item %1 is blocked.', ItemNo);

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Location Code", SelectedLocation);
        ItemLedgerEntry.CalcSums("Remaining Quantity");
        AvailableQty := ItemLedgerEntry."Remaining Quantity";

        TempScanLine.Reset();
        TempScanLine.SetRange("Item No.", ItemNo);
        if TempScanLine.FindFirst() then begin
            RequestedQty := TempScanLine.Quantity + DefaultQty;
            if RequestedQty > AvailableQty then
                Error('Insufficient stock for item %1 at location %2. Available: %3; requested total: %4.',
                    ItemNo, SelectedLocation, AvailableQty, RequestedQty);
            TempScanLine.Quantity := RequestedQty;
            TempScanLine.Barcode := BarcodeValue;
            TempScanLine."Available Quantity" := AvailableQty;
            TempScanLine.Modify();
        end else begin
            if DefaultQty > AvailableQty then
                Error('Insufficient stock for item %1 at location %2. Available: %3; requested: %4.',
                    ItemNo, SelectedLocation, AvailableQty, DefaultQty);
            TempScanLine.Reset();
            if TempScanLine.FindLast() then
                NextEntryNo := TempScanLine."Entry No." + 1
            else
                NextEntryNo := 1;
            TempScanLine.Init();
            TempScanLine."Entry No." := NextEntryNo;
            TempScanLine."Item No." := ItemNo;
            TempScanLine.Description := Item.Description;
            TempScanLine.Barcode := BarcodeValue;
            TempScanLine.Quantity := DefaultQty;
            TempScanLine."Unit of Measure Code" := Item."Base Unit of Measure";
            TempScanLine."Available Quantity" := AvailableQty;
            TempScanLine.Insert();
        end;

        LastItemNo := Item."No.";
        LastItemDesc := Item.Description;
        LastQty := DefaultQty;
    end;

    local procedure ValidateBeforePosting()
    begin
        if PostingDate = 0D then
            Error('Posting Date is required.');
        if SelectedLocation = '' then
            Error('Location Code is mandatory.');
        TempScanLine.Reset();
        if TempScanLine.IsEmpty() then
            Error('Scan at least one item before previewing or posting.');
    end;

    local procedure PostPendingConsumption()
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        TemplateName: Code[10];
        BatchName: Code[10];
        NextLineNo: Integer;
        DocNo: Code[20];
        AvailableQty: Decimal;
        PostedCount: Integer;
    begin
        ValidateBeforePosting();
        if not Confirm('Post %1 pending line(s) from location %2 with posting date %3?',
            false, TempScanLine.Count(), SelectedLocation, PostingDate)
        then
            exit;

        TemplateName := 'ITEM';
        BatchName := 'DEFAULT';
        DocNo := CopyStr('SCAN' + Format(PostingDate, 0, '<Year4><Month,2><Day,2>'),
            1, MaxStrLen(DocNo));

        // Validate all lines' current stock before starting to post.
        TempScanLine.Reset();
        if TempScanLine.FindSet() then
            repeat
                Item.Get(TempScanLine."Item No.");
                Item.SetRange("Location Filter", SelectedLocation);
                Item.CalcFields(Inventory);
                AvailableQty := Item.Inventory;
                Item.SetRange("Location Filter");
                if TempScanLine.Quantity <= 0 then
                    Error('Quantity must be greater than zero for item %1.', TempScanLine."Item No.");
                if TempScanLine.Quantity > AvailableQty then
                    Error('Insufficient stock for item %1 at location %2. Available: %3; requested: %4.',
                        TempScanLine."Item No.", SelectedLocation, AvailableQty, TempScanLine.Quantity);
            until TempScanLine.Next() = 0;

        // Post each item as a standard negative adjustment.
        TempScanLine.Reset();
        if TempScanLine.FindSet() then
            repeat
                ItemJnlLine.Reset();
                ItemJnlLine.SetRange("Journal Template Name", TemplateName);
                ItemJnlLine.SetRange("Journal Batch Name", BatchName);
                if ItemJnlLine.FindLast() then
                    NextLineNo := ItemJnlLine."Line No." + 10000
                else
                    NextLineNo := 10000;

                ItemJnlLine.Init();
                ItemJnlLine."Journal Template Name" := TemplateName;
                ItemJnlLine."Journal Batch Name" := BatchName;
                ItemJnlLine."Line No." := NextLineNo;
                ItemJnlLine.Validate("Posting Date", PostingDate);
                ItemJnlLine.Validate("Document Date", PostingDate);
                ItemJnlLine."Document No." := DocNo;
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                ItemJnlLine.Validate("Item No.", TempScanLine."Item No.");
                ItemJnlLine.Validate("Location Code", SelectedLocation);
                ItemJnlLine.Validate("Unit of Measure Code", TempScanLine."Unit of Measure Code");
                ItemJnlLine.Validate(Quantity, TempScanLine.Quantity);
                ItemJnlLine.Insert(true);
                ItemJnlPostLine.RunWithCheck(ItemJnlLine);

                if ItemJnlLine.Get(TemplateName, BatchName, NextLineNo) then
                    ItemJnlLine.Delete();
                PostedCount += 1;
            until TempScanLine.Next() = 0;

        TempScanLine.Reset();
        TempScanLine.DeleteAll();
        Clear(ScannedBarcode);
        Clear(LastItemNo);
        Clear(LastItemDesc);
        Clear(LastQty);
        CurrPage.ScanLines.Page.SetBuffer(TempScanLine);
        CurrPage.Update(false);

        Message('%1 consumption line(s) posted successfully. Document No.: %2.',
            PostedCount, DocNo);
    end;
}
