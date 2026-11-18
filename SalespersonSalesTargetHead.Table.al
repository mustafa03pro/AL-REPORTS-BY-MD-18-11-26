
table 50301 "Salesperson Sales Target Head"
{
    Caption = 'Salesperson Sales Target Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Target No.';
            NotBlank = true;
        }

        field(2; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser".Code;

            trigger OnValidate()
            begin
                if "Salesperson Code" <> '' then begin
                    SalespersonRec.Get("Salesperson Code");
                    "Salesperson Name" := SalespersonRec.Name;
                end else
                    Clear("Salesperson Name");
            end;
        }

        field(3; "Salesperson Name"; Text[100])
        {
            Caption = 'Salesperson Name';
            Editable = false;
        }

        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(5; "Period Type"; Enum "Salesperson Target Period")
        {
            Caption = 'Period Type';
        }

        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                CheckDateRange();
            end;
        }

        field(7; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                CheckDateRange();
            end;
        }

        field(8; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }

        field(9; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }

        key(SalespersonPeriod;
        "Salesperson Code",
            "Period Type",
            "Start Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created Date" = 0D then
            "Created Date" := Today;

        if "Created By" = '' then
            "Created By" :=
                CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;

    trigger OnDelete()
    var
        TargetLine: Record "Salesperson Sales Target Line";
    begin
        TargetLine.SetRange("Target No.", "No.");

        if not TargetLine.IsEmpty() then
            TargetLine.DeleteAll(true);
    end;

    local procedure CheckDateRange()
    begin
        if ("Start Date" <> 0D) and
           ("End Date" <> 0D) then
            if "Start Date" > "End Date" then
                Error(
                    'Start Date cannot be greater than End Date.');
    end;

    var
        SalespersonRec: Record "Salesperson/Purchaser";
}
