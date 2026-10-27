pageextension 50266 "Item Ledger Secondary UOM" extends "Item Ledger Entries"
{
    layout
    {
        addafter(Quantity)
        {
            field("Secondary Unit Code"; SecondaryUnitCode)
            {
                ApplicationArea = All;
                Caption = 'Secondary Unit Code';
                Editable = false;
            }

            field("Quantity in Secondary UOM"; SecondaryQuantity)
            {
                ApplicationArea = All;
                Caption = 'Quantity in Secondary UOM';
                DecimalPlaces = 0 : 3;
                Editable = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculateSecondaryQuantity();
    end;

    var
        SecondaryUnitCode: Code[10];
        SecondaryQuantity: Decimal;

    local procedure CalculateSecondaryQuantity()
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        QtyPerUOM: Decimal;
    begin
        Clear(SecondaryUnitCode);
        Clear(SecondaryQuantity);

        if not Item.Get(Rec."Item No.") then
            exit;

        ItemUOM.SetRange("Item No.", Item."No.");
        ItemUOM.SetFilter(Code, '<>%1', Item."Base Unit of Measure");

        if not ItemUOM.FindFirst() then
            exit;

        SecondaryUnitCode := ItemUOM.Code;
        QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

        if QtyPerUOM = 0 then
            exit;

        SecondaryQuantity := Rec.Quantity / QtyPerUOM;
    end;
}