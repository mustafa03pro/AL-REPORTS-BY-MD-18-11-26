// page 50232 "Transfer Scan Lines"
// {
//     PageType = ListPart;
//     SourceTable = "Transfer Scan Buffer";
//     SourceTableTemporary = true;
//     Caption = 'Scanned Transfer Items';
//     ApplicationArea = All;
//     Editable = false;

//     layout
//     {
//         area(content)
//         {
//             repeater(Lines)
//             {
//                 field("Item No."; Rec."Item No.")
//                 {
//                     ApplicationArea = All;
//                 }

//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = All;
//                 }

//                 field(Barcode; Rec.Barcode)
//                 {
//                     ApplicationArea = All;
//                 }

//                 field(Quantity; Rec.Quantity)
//                 {
//                     ApplicationArea = All;
//                 }

//                 field("Unit of Measure Code";
//                 Rec."Unit of Measure Code")
//                 {
//                     ApplicationArea = All;
//                 }

//                 field("Available Quantity";
//                 Rec."Available Quantity")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }

//     procedure SetBuffer(
//         var TempBuffer: Record "Transfer Scan Buffer" temporary)
//     begin
//         Rec.Copy(TempBuffer, true);
//         CurrPage.Update(false);
//     end;
// }



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

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }

                field("Available Quantity"; Rec."Available Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteTransferLine)
            {
                ApplicationArea = All;
                Caption = 'Delete Line';
                Image = Delete;
                ToolTip = 'Delete the selected scanned item before creating the transfer.';

                trigger OnAction()
                begin
                    if Rec."Entry No." = 0 then
                        Error('Select a scanned item to delete.');

                    if not Confirm(
                        'Do you want to delete item %1 - %2 from the scanned transfer list?',
                        false,
                        Rec."Item No.",
                        Rec.Description)
                    then
                        exit;

                    Rec.Delete();

                    CurrPage.Update(false);

                    Message('Scanned item deleted successfully.');
                end;
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
