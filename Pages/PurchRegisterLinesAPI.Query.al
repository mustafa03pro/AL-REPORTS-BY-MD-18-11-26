// query 50201 "Purch Register Lines API"
// {
//     QueryType = API;
//     APIPublisher = 'custom';
//     APIGroup = 'purchasing';
//     APIVersion = 'v2.0';
//     EntityName = 'purchaseInvoiceLine';
//     EntitySetName = 'purchaseInvoiceLines';
//     Caption = 'Purchase Invoice Lines API';

//     elements
//     {
//         dataitem(PurchInvHeader; "Purch. Inv. Header")
//         {
//             column(postingDate; "Posting Date") { }
//             column(vendorNo; "Buy-from Vendor No.") { }
//             column(vendorName; "Buy-from Vendor Name") { }
//             column(invoiceNo; "No.") { }
//             column(currencyCode; "Currency Code") { }

//             dataitem(PurchInvLine; "Purch. Inv. Line")
//             {
//                 DataItemLink = "Document No." = PurchInvHeader."No.";
//                 SqlJoinType = InnerJoin;

//                 // Replicates your AL condition: Type <> ' ' AND "No." <> ''
//                 DataItemTableFilter = Type = filter(<> " "), "No." = filter(<> '');

//                 column(lineNo; "Line No.") { }
//                 column(lineType; Type) { }
//                 column(itemNo; "No.") { }
//                 column(itemDescription; Description) { }
//                 column(unitOfMeasure; "Unit of Measure Code") { }
//                 column(quantity; Quantity) { }
//                 column(unitCost; "Direct Unit Cost") { }
//                 column(amount; Amount) { }
//                 column(vatPercent; "VAT %") { }
//                 column(amountIncludingVAT; "Amount Including VAT") { }
//                 column(locationCode; "Location Code") { }
//                 column(postingGroup; "Posting Group") { }
//             }
//         }
//     }
// }

query 50201 "Purch Register Lines API"
{
    QueryType = API;
    APIPublisher = 'metworld';
    APIGroup = 'purchasing';
    APIVersion = 'v1.0';
    EntityName = 'purchaseInvoiceLine';
    EntitySetName = 'purchaseInvoiceLines';
    Caption = 'Purchase Invoice Lines API';

    elements
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            column(postingDate; "Posting Date") { }
            column(vendorNo; "Buy-from Vendor No.") { }
            column(vendorName; "Buy-from Vendor Name") { }
            column(invoiceNo; "No.") { }
            column(currencyCode; "Currency Code") { }

            dataitem(PurchInvLine; "Purch. Inv. Line")
            {
                DataItemLink = "Document No." = PurchInvHeader."No.";
                SqlJoinType = InnerJoin;

                DataItemTableFilter = Type = filter(<> " "), "No." = filter(<> '');

                column(lineNo; "Line No.") { }
                column(lineType; Type) { }
                column(itemNo; "No.") { }
                column(itemDescription; Description) { }
                column(unitOfMeasure; "Unit of Measure Code") { }
                column(quantity; Quantity) { }
                column(unitCost; "Direct Unit Cost") { }
                column(amount; Amount) { }
                column(vatPercent; "VAT %") { }
                column(amountIncludingVAT; "Amount Including VAT") { }
                column(locationCode; "Location Code") { }
                column(postingGroup; "Posting Group") { }
            }
        }
    }
}