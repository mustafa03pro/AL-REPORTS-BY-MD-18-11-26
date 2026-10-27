table 50251 "Purchase Indent Line"
{
    Caption = 'Purchase Indent Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Indent No."; Code[20])
        {
            Caption = 'Indent No.';
            TableRelation = "Purchase Indent Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            InitValue = Item;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if ItemRec.Get("No.") then begin
                    Description := ItemRec.Description;
                    "Unit of Measure Code" := ItemRec."Base Unit of Measure";
                end;
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure".Code;
        }

        field(50252; "Existing Inventory"; Decimal)
        {
            Caption = 'Existing Inventory';
            FieldClass = FlowField;
            Editable = false;
            DecimalPlaces = 0 : 5;

            CalcFormula = sum("Item Ledger Entry".Quantity
        where(
            "Item No." = field("No."),
            "Location Code" = field("Location Code")
        ));
        }

        // field(8; "Quantity Requested"; Decimal)
        // {
        //     Caption = 'Quantity Requested';
        //     DecimalPlaces = 0 : 5;
        //     MinValue = 0;
        // }
        field(8; "Quantity Requested"; Decimal)
        {
            Caption = 'Quantity Requested';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Quantity Requested" < "Quantity Ordered" then
                    Error(
                        'Requested quantity cannot be less than the quantity already ordered.');

                if "Qty. to Order" >
                   "Quantity Requested" - "Quantity Ordered"
                then
                    Validate(
                        "Qty. to Order",
                        "Quantity Requested" - "Quantity Ordered");
            end;
        }
        field(9; "Quantity Ordered"; Decimal)
        {
            Caption = 'Quantity Ordered';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // field(10; "Qty. to Order"; Decimal)
        // {
        //     Caption = 'Qty. to Order';
        //     DecimalPlaces = 0 : 5;
        //     MinValue = 0;
        // }
        field(10; "Qty. to Order"; Decimal)
        {
            Caption = 'Qty. to Order';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                RemainingQty: Decimal;
            begin
                RemainingQty :=
                    "Quantity Requested" - "Quantity Ordered";

                if "Qty. to Order" > RemainingQty then
                    Error(
                        'Qty. to Order cannot exceed the remaining quantity of %1.',
                        RemainingQty);
            end;
        }
        field(11; "Required Date"; Date)
        {
            Caption = 'Required Date';
        }
        field(12; "Purchase Order No."; Code[20])
        {
            Caption = 'Last Purchase Order No.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Indent No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Qty. to Order" = 0 then
            "Qty. to Order" := "Quantity Requested";
    end;
}