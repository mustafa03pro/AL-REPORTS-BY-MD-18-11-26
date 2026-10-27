// pageextension 50265 "Sales Invoice Secondary UOM" extends "Sales Invoice Subform"
// {
//     layout
//     {
//         addafter(Quantity)
//         {
//             field("Secondary Unit Code"; SecondaryUnitCode)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Secondary Unit Code';
//                 Editable = false;
//             }

//             field("Inventory in Secondary UOM"; SecondaryInventory)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Inventory in Secondary UOM';
//                 DecimalPlaces = 0 : 5;
//                 Editable = false;
//             }
//         }
//     }

//     trigger OnAfterGetRecord()
//     begin
//         CalculateSecondaryInventory();
//     end;

//     var
//         SecondaryUnitCode: Code[10];
//         SecondaryInventory: Decimal;

//     local procedure CalculateSecondaryInventory()
//     var
//         Item: Record Item;
//         ItemUOM: Record "Item Unit of Measure";
//         QtyPerUOM: Decimal;
//     begin
//         Clear(SecondaryUnitCode);
//         Clear(SecondaryInventory);

//         if Rec.Type <> Rec.Type::Item then
//             exit;

//         if not Item.Get(Rec."No.") then
//             exit;

//         ItemUOM.SetRange("Item No.", Item."No.");
//         ItemUOM.SetFilter(Code, '<>%1', Item."Base Unit of Measure");

//         if not ItemUOM.FindFirst() then
//             exit;

//         SecondaryUnitCode := ItemUOM.Code;
//         QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

//         if QtyPerUOM = 0 then
//             exit;

//         Item.SetRange("Location Filter", Rec."Location Code");
//         Item.CalcFields(Inventory);

//         SecondaryInventory := Item.Inventory / QtyPerUOM;
//     end;
// }