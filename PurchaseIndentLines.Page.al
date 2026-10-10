// page 50252 "Purchase Indent Lines"
// {
//     Caption = 'Indent Lines';
//     PageType = ListPart;
//     SourceTable = "Purchase Indent Line";
//     ApplicationArea = All;
//     AutoSplitKey = true;
//     DelayedInsert = true;
//     MultipleNewLines = true;

//     layout
//     {
//         area(Content)
//         {
//             repeater(Lines)
//             {
//                 field("No."; Rec."No.")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Item No.';
//                     ShowMandatory = true;
//                 }
//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Location Code"; Rec."Location Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Quantity Requested"; Rec."Quantity Requested")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Unit of Measure Code"; Rec."Unit of Measure Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Required Date"; Rec."Required Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Quantity Ordered"; Rec."Quantity Ordered")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Qty. to Order"; Rec."Qty. to Order")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
// }


page 50252 "Purchase Indent Lines"
{
    Caption = 'Indent Lines';
    PageType = ListPart;
    SourceTable = "Purchase Indent Line";
    ApplicationArea = All;
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Quantity Requested"; Rec."Quantity Requested")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Required Date"; Rec."Required Date")
                {
                    ApplicationArea = All;
                }
                field("Quantity Ordered"; Rec."Quantity Ordered")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Order"; Rec."Qty. to Order")
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
            action(CreatePurchaseOrder)
            {
                Caption = 'Create Purchase Order';
                ApplicationArea = All;
                Image = CreateOrder;
                ToolTip = 'Create a purchase order from the selected indent lines.';

                trigger OnAction()
                var
                    IndentLine: Record "Purchase Indent Line";
                    CreateIndentPO: Codeunit "Indent to Purchase Order";
                begin
                    CurrPage.SetSelectionFilter(IndentLine);

                    if IndentLine.IsEmpty() then
                        Error('Select at least one indent line.');

                    CreateIndentPO.CreatePurchaseOrder(
                        Rec."Indent No.",
                        IndentLine);
                end;
            }
        }
    }
}