page 50232 "Transfer Scan Lines"
{
    PageType = ListPart;
    SourceTable = "Transfer Scan Buffer";
    SourceTableTemporary = true;
    Caption = 'Scanned Transfer Items';
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field(Barcode; Rec.Barcode)
                {
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }

                field("Unit of Measure Code";
                Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }

                field("Available Quantity";
                Rec."Available Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetBuffer(
        var TempBuffer: Record "Transfer Scan Buffer" temporary)
    begin
        Rec.Copy(TempBuffer, true);
        CurrPage.Update(false);
    end;
}