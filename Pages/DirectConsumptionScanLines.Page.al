page 50241 "Direct Consumption Scan Lines"
{
    PageType = ListPart;
    SourceTable = "Direct Consumption Scan Line";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Scanned Consumption Items';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; Editable = false; }
                field(Description; Rec.Description) { ApplicationArea = All; Editable = false; }
                field(Barcode; Rec.Barcode) { ApplicationArea = All; Editable = false; }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 5;
                    trigger OnValidate()
                    begin
                        if Rec.Quantity <= 0 then
                            Error('Consumption quantity must be greater than zero.');
                        if Rec.Quantity > Rec."Available Quantity" then
                            Error('Quantity for item %1 cannot exceed available stock %2.',
                                Rec."Item No.", Rec."Available Quantity");
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; Editable = false; }
                field("Available Quantity"; Rec."Available Quantity") { ApplicationArea = All; Editable = false; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DeleteScannedLine)
            {
                ApplicationArea = All;
                Caption = 'Delete Line';
                Image = DeleteLine;
                trigger OnAction()
                begin
                    if Rec.IsEmpty() then
                        exit;
                    if Confirm('Delete item %1 from the pending list?', false, Rec."Item No.") then
                        Rec.Delete();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure SetBuffer(var Buffer: Record "Direct Consumption Scan Line" temporary)
    begin
        Rec.Copy(Buffer, true);
        CurrPage.Update(false);
    end;
}
