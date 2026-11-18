
table 50302 "Salesperson Sales Target Line"
{
    Caption = 'Salesperson Sales Target Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Target No."; Code[20])
        {
            Caption = 'Target No.';
            TableRelation =
                "Salesperson Sales Target Head"."No.";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group".Code;

            trigger OnValidate()
            var
                ExistingLine: Record "Salesperson Sales Target Line";
            begin
                if "Inventory Posting Group" = '' then
                    exit;

                ExistingLine.SetRange("Target No.", "Target No.");
                ExistingLine.SetRange(
                    "Inventory Posting Group",
                    "Inventory Posting Group");

                ExistingLine.SetFilter(
                    "Line No.", '<>%1', "Line No.");

                if not ExistingLine.IsEmpty() then
                    Error(
                        'This Inventory Posting Group already exists in this target document.');
            end;
        }

        field(4; "Target Quantity"; Decimal)
        {
            Caption = 'Target Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }

        field(5; "Target Revenue"; Decimal)
        {
            Caption = 'Target Revenue';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }

        field(6; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Target No.", "Line No.")
        {
            Clustered = true;
        }

        key(PostingGroup; "Target No.", "Inventory Posting Group")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    begin
        if "Created Date" = 0D then
            "Created Date" := Today;
    end;
}
