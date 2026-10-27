table 50201 "Purchase Register Combined"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer) { }
        field(2; Date; Date) { }
        field(3; VendorCode; Code[20]) { }
        field(4; VendorName; Text[100]) { }
        field(5; InvoiceNo; Code[20]) { }
        field(6; ItemNo; Code[20]) { }
        field(7; ItemDescription; Text[100]) { }
        field(8; Quantity; Decimal) { }
        field(9; UnitCost; Decimal) { }
        field(10; Amount; Decimal) { }
        field(11; VATAmount; Decimal) { }
        field(12; TotalAmount; Decimal) { }
        field(13; "Purchase Account"; Code[20])
        {
            Caption = 'Purchase Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
    }
}