table 50231 "Transfer Scan Buffer"
{
    Caption = 'Transfer Scan Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }

        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }

        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(4; Barcode; Code[50])
        {
            Caption = 'Barcode';
        }

        field(5; Quantity; Decimal)
        {
            Caption = 'Transfer Quantity';
            DecimalPlaces = 0 : 5;
        }

        field(6; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure".Code;
        }

        field(7; "Available Quantity"; Decimal)
        {
            Caption = 'Available at Source';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}