// page 50161 "Sales Register BI API"
// {
//     PageType = API;
//     Caption = 'Sales Register BI API';

//     APIPublisher = 'metworld';
//     APIGroup = 'reports';
//     APIVersion = 'v1.0';

//     EntityName = 'salesRegisterLine';
//     EntitySetName = 'salesRegisterLines';

//     SourceTable = "Sales Register BI Data";
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
//                 field(id; Rec.SystemId) { }
//                 field(postingDate; Rec."Posting Date") { }
//                 field(customerCode; Rec."Customer Code") { }
//                 field(customerName; Rec."Customer Name") { }
//                 field(documentNumber; Rec."Document No.") { }
//                 field(documentType; Rec."Document Type") { }
//                 field(salesOrderNumber; Rec."Sales Order No.") { }
//                 field(salesperson; Rec.Salesperson) { }
//                 field(itemNumber; Rec."Item No.") { }
//                 field(description; Rec."Item Description") { }
//                 field(quantityMT; Rec."Quantity MT") { }
//                 field(bundles; Rec.Bundles) { }
//                 field(pieces; Rec.Pieces) { }
//                 field(salesUOMQuantity; Rec."Sales UOM Quantity") { }
//                 field(salesUOMCode; Rec."Sales UOM Code") { }
//                 field(baseUOMQuantity; Rec."Base UOM Quantity") { }
//                 field(baseUOMCode; Rec."Base UOM Code") { }
//                 field(basicValue; Rec."Basic Value") { }
//                 field(vatAmount; Rec."VAT Amount") { }
//                 field(grossTotal; Rec."Gross Total") { }
//             }
//         }
//     }
// }