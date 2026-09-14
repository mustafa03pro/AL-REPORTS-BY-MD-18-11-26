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

                field(ScannedBarcode; ScannedBarcode)
                {
                    ApplicationArea = All;
                    Caption = 'Scan Barcode / GTIN';
                    ToolTip = 'Scan or type GTIN/Barcode and press Enter.';
                    QuickEntry = true;

                    trigger OnValidate()
                    begin
                        if ScannedBarcode <> '' then begin
                            ProcessConsumption(ScannedBarcode);
                            ScannedBarcode := '';
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(SelectedLocation; SelectedLocation)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location;
                    ToolTip = 'Select the warehouse/store location to adjust stock from.';
                }
                field(DefaultQty; DefaultQty)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity per Scan';
                    ToolTip = 'Default quantity to reduce per barcode scan.';
                }
            }
            group(LastScanInfo)
            {
                Caption = 'Last Scanned Item Details';

                field(LastItemNo; LastItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Editable = false;
                }
                field(LastItemDesc; LastItemDesc)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                }
                field(LastQty; LastQty)
                {
                    ApplicationArea = All;
                    Caption = 'Reduced Qty';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        DefaultQty := 1;
    end;

    var
        ScannedBarcode: Code[50];
        SelectedLocation: Code[10];
        DefaultQty: Decimal;
        LastItemNo: Code[20];
        LastItemDesc: Text[100];
        LastQty: Decimal;

    local procedure ProcessConsumption(Barcode: Code[50])
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemNo: Code[20];
        TemplateName: Code[10];
        BatchName: Code[10];
        NextLineNo: Integer;
        DocNo: Code[20];
    begin
        TemplateName := 'ITEM';
        BatchName := 'DEFAULT';
        ItemNo := '';

        // 1. Resolve Barcode / GTIN to Item No.
        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        ItemRef.SetRange("Reference No.", Barcode);
        if ItemRef.FindFirst() then
            ItemNo := ItemRef."Item No."
        else begin
            Item.SetRange(GTIN, Barcode);
            if Item.FindFirst() then
                ItemNo := Item."No."
            else
                if Item.Get(Barcode) then
                    ItemNo := Item."No.";
        end;

        if ItemNo = '' then
            Error('No item found matching Barcode/GTIN: %1', Barcode);

        // 2. Validate Item Type
        Item.Get(ItemNo);
        if Item.Type <> Item.Type::Inventory then
            Error('Item %1 must be set to Type = Inventory.', ItemNo);

        // 3. Determine Line No and Generate Document No
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLine.FindLast() then
            NextLineNo := ItemJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        DocNo := 'SCAN' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>');

        // 4. Populate and Insert Item Journal Line
        ItemJnlLine.Init();
        ItemJnlLine."Journal Template Name" := TemplateName;
        ItemJnlLine."Journal Batch Name" := BatchName;
        ItemJnlLine."Line No." := NextLineNo;
        ItemJnlLine."Posting Date" := WorkDate();
        ItemJnlLine."Document Date" := WorkDate();
        ItemJnlLine."Document No." := DocNo;
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";

        ItemJnlLine.Validate("Item No.", ItemNo);

        if SelectedLocation <> '' then
            ItemJnlLine.Validate("Location Code", SelectedLocation);

        ItemJnlLine.Validate(Quantity, DefaultQty);
        ItemJnlLine.Insert(true);

        // 5. Direct Post Line cleanly
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        // 6. Clean up temporary journal entry
        if ItemJnlLine.Get(TemplateName, BatchName, NextLineNo) then
            ItemJnlLine.Delete();

        // 7. Update UI
        LastItemNo := Item."No.";
        LastItemDesc := Item.Description;
        LastQty := DefaultQty;
    end;
}