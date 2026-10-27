
// page 50285 "Item Units of Measure API"
// {
//     PageType = API;
//     Caption = 'Item Units of Measure API';

//     APIPublisher = 'metworld';
//     APIGroup = 'inventory';
//     APIVersion = 'v1.0';

//     EntityName = 'itemUnitOfMeasure';
//     EntitySetName = 'itemUnitsOfMeasures';

//     SourceTable = "Item Unit of Measure";
//     ODataKeyFields = SystemId;

//     InsertAllowed = false;
//     ModifyAllowed = false;
//     DeleteAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field(id; Rec.SystemId)
//                 {
//                     Caption = 'ID';
//                 }

//                 field(itemNo; Rec."Item No.")
//                 {
//                     Caption = 'Item No.';
//                 }

//                 field(code; Rec.Code)
//                 {
//                     Caption = 'Unit of Measure Code';
//                 }

//                 field(qtyPerUnitOfMeasure;
//                 Rec."Qty. per Unit of Measure")
//                 {
//                     Caption = 'Qty. per Unit of Measure';
//                 }

//                 field(height; Rec.Height)
//                 {
//                     Caption = 'Height';
//                 }

//                 field(width; Rec.Width)
//                 {
//                     Caption = 'Width';
//                 }

//                 field(length; Rec.Length)
//                 {
//                     Caption = 'Length';
//                 }

//                 field(cubage; Rec.Cubage)
//                 {
//                     Caption = 'Cubage';
//                 }

//                 field(weight; Rec.Weight)
//                 {
//                     Caption = 'Weight';
//                 }
//             }
//         }
//     }
// }

// page 50285 "Item Units of Measure API"
// {
//     PageType = API;
//     Caption = 'Item Units of Measure API';

//     APIPublisher = 'metworld';
//     APIGroup = 'reports';
//     APIVersion = 'v1.0';

//     EntityName = 'itemUnitOfMeasure';
//     EntitySetName = 'itemUnitsOfMeasures';

//     SourceTable = "Item Unit of Measure";
//     ODataKeyFields = SystemId;

//     InsertAllowed = false;
//     ModifyAllowed = false;
//     DeleteAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field(id; Rec.SystemId)
//                 {
//                     Caption = 'ID';
//                 }

//                 field(itemNo; Rec."Item No.")
//                 {
//                     Caption = 'Item No.';
//                 }

//                 field(code; Rec.Code)
//                 {
//                     Caption = 'Unit of Measure Code';
//                 }

//                 field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
//                 {
//                     Caption = 'Qty. per Unit of Measure';
//                 }

//                 field(height; Rec.Height)
//                 {
//                     Caption = 'Height';
//                 }

//                 field(width; Rec.Width)
//                 {
//                     Caption = 'Width';
//                 }

//                 field(length; Rec.Length)
//                 {
//                     Caption = 'Length';
//                 }

//                 field(cubage; Rec.Cubage)
//                 {
//                     Caption = 'Cubage';
//                 }

//                 field(weight; Rec.Weight)
//                 {
//                     Caption = 'Weight';
//                 }
//             }
//         }
//     }
// }
page 50285 "Item Units of Measure API"
{
    PageType = API;
    Caption = 'Item Units of Measure API';

    APIPublisher = 'metworld';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';

    EntityName = 'itemUnitOfMeasure';
    EntitySetName = 'itemUnitsOfMeasures';

    SourceTable = "Item Unit of Measure";
    ODataKeyFields = SystemId;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'ID';
                }

                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }

                field(code; Rec.Code)
                {
                    Caption = 'Unit of Measure Code';
                }

                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure';
                }

                field(height; Rec.Height)
                {
                    Caption = 'Height';
                }

                field(width; Rec.Width)
                {
                    Caption = 'Width';
                }

                field(length; Rec.Length)
                {
                    Caption = 'Length';
                }

                field(cubage; Rec.Cubage)
                {
                    Caption = 'Cubage';
                }

                field(weight; Rec.Weight)
                {
                    Caption = 'Weight';
                }
            }
        }
    }
}