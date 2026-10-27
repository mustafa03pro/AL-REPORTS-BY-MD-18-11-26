page 50242 "Direct Consumption Preview"
{
    PageType = List;
    SourceTable = "Direct Consumption Scan Line";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Preview Consumption Posting';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Barcode; Rec.Barcode) { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; DecimalPlaces = 0 : 5; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; }
                field("Available Quantity"; Rec."Available Quantity") { ApplicationArea = All; }
            }
        }
    }

    procedure SetBuffer(var Buffer: Record "Direct Consumption Scan Line" temporary)
    begin
        Rec.Copy(Buffer, true);
        CurrPage.Update(false);
    end;
}

