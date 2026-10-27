
table 50256 "Purchase Indent History"
{
    Caption = 'Purchase Indent History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Indent No."; Code[20])
        {
            TableRelation = "Purchase Indent Header"."No.";
        }
        field(3; "Indent Line No."; Integer)
        {
        }
        field(4; "Purchase Order No."; Code[20])
        {
            TableRelation = "Purchase Header"."No."
                where("Document Type" =
                    const(Order));
        }
        field(5; "Purchase Order Line No."; Integer)
        {
        }
        field(6; "Vendor No."; Code[20])
        {
            TableRelation = Vendor."No.";
        }
        field(7; "Vendor Name"; Text[100])
        {
        }
        field(8; "Item No."; Code[20])
        {
            TableRelation = Item."No.";
        }
        field(9; Description; Text[100])
        {
        }
        field(10; "Quantity Ordered"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
        }
        field(12; "Order Date"; Date)
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(IndentKey; "Indent No.", "Indent Line No.")
        {
        }
    }
}
