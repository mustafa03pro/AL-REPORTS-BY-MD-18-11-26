page 50150 "Posted Sales Invoice Lines API"
{
    PageType = API;

    SourceTable = "Sales Invoice Line";

    APIPublisher = 'metworld';
    APIGroup = 'sales';
    APIVersion = 'v1.0';

    EntityName = 'salesInvoiceLine';
    EntitySetName = 'salesInvoiceLines';

    DelayedInsert = true;

    layout
    {
        area(content)
        {
            field(id; Rec.SystemId)
            {
            }

            field(documentNumber; Rec."Document No.")
            {
            }

            field(lineNumber; Rec."Line No.")
            {
            }

            field(postingDate; Rec."Posting Date")
            {
            }

            field(customerNumber; Rec."Sell-to Customer No.")
            {
            }

            field(itemNumber; Rec."No.")
            {
            }

            field(description; Rec.Description)
            {
            }

            field(unitOfMeasure; Rec."Unit of Measure Code")
            {
            }

            field(quantity; Rec.Quantity)
            {
            }

            field(unitPrice; Rec."Unit Price")
            {
            }

            field(lineAmount; Rec."Line Amount")
            {
            }

            field(amountIncludingVAT; Rec."Amount Including VAT")
            {
            }

            field(locationCode; Rec."Location Code")
            {
            }

            field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
            {
            }
        }
    }
}