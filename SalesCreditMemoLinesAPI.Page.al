
// page 50162 "Sales Credit Memo Lines API"
// {
//     PageType = API;
//     Caption = 'Sales Credit Memo Lines API';

//     APIPublisher = 'metworld';
//     APIGroup = 'sales';
//     APIVersion = 'v1.0';

//     EntityName = 'salesCreditMemoLine';
//     EntitySetName = 'salesCreditMemoLines';

//     SourceTable = "Sales Cr.Memo Line";
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
//                 }

//                 field(documentNumber; Rec."Document No.")
//                 {
//                 }

//                 field(lineNumber; Rec."Line No.")
//                 {
//                 }

//                 field(itemNumber; Rec."No.")
//                 {
//                 }

//                 field(description; Rec.Description)
//                 {
//                 }

//                 field(quantity; Rec.Quantity)
//                 {
//                 }

//                 field(unitOfMeasure; Rec."Unit of Measure Code")
//                 {
//                 }

//                 field(unitPrice; Rec."Unit Price")
//                 {
//                 }

//                 field(lineAmount; Rec."Line Amount")
//                 {
//                 }

//                 field(amountIncludingVAT; Rec."Amount Including VAT")
//                 {
//                 }

//                 field(locationCode; Rec."Location Code")
//                 {
//                 }
//             }
//         }
//     }
// }


query 50162 "Sales Credit Memo Lines API"
{
    QueryType = API;

    APIPublisher = 'mustafametworld';
    APIGroup = 'sales';
    APIVersion = 'v1.0';

    EntityName = 'salesCreditMemoLine';
    EntitySetName = 'salesCreditMemoLines';

    Caption = 'Sales Credit Memo Lines API';

    elements
    {
        dataitem(SalesCrMemoLine; "Sales Cr.Memo Line")
        {
            column(id; SystemId) { }
            column(documentNumber; "Document No.") { }
            column(lineNumber; "Line No.") { }
            column(itemNumber; "No.") { }
            column(description; Description) { }
            column(quantity; Quantity) { }
            column(unitOfMeasure; "Unit of Measure Code") { }
            column(unitPrice; "Unit Price") { }
            column(lineAmount; "Line Amount") { }
            column(amountIncludingVAT; "Amount Including VAT") { }
            column(locationCode; "Location Code") { }
        }
    }
}
