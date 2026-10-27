pageextension 50263 "Item List Secondary UOM" extends "Item List"
{
    layout
    {

        addafter("No.")
        {
            field("Secondary Unit Code"; GetSecondaryUnitCode())
            {
                ApplicationArea = All;
                Caption = 'Secondary Unit Code';
                ToolTip = 'Shows the secondary unit of measure configured for this item.';
            }

            field("Inventory in Secondary UOM"; GetSecondaryInventory())
            {
                ApplicationArea = All;
                Caption = 'Inventory in Secondary UOM';
                DecimalPlaces = 0 : 3;
                ToolTip = 'Shows the equivalent inventory in the secondary unit of measure.';
            }
        }
    }

    local procedure GetSecondaryUnitCode(): Code[10]
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.SetRange("Item No.", Rec."No.");
        ItemUOM.SetFilter(Code, '<>%1', Rec."Base Unit of Measure");

        if ItemUOM.FindFirst() then
            exit(ItemUOM.Code);

        exit('');
    end;



    local procedure GetSecondaryInventory(): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
        QtyPerUOM: Decimal;
    begin
        ItemUOM.SetRange("Item No.", Rec."No.");
        ItemUOM.SetFilter(Code, '<>%1', Rec."Base Unit of Measure");

        if not ItemUOM.FindFirst() then
            exit(0);

        QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

        if QtyPerUOM = 0 then
            exit(0);

        exit(Round(Rec.Inventory / QtyPerUOM, 0.001, '='));
    end;
}

// local procedure GetSecondaryInventory(): Decimal
// var
//     ItemUOM: Record "Item Unit of Measure";
//     QtyPerUOM: Decimal;
// begin
//     ItemUOM.SetRange("Item No.", Rec."No.");
//     ItemUOM.SetFilter(Code, '<>%1', Rec."Base Unit of Measure");

//     if not ItemUOM.FindFirst() then
//         exit(0);

//     QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

//     if QtyPerUOM = 0 then
//         exit(0);

//     exit(Rec.Inventory / QtyPerUOM);
// end;