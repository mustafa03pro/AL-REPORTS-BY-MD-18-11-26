// table 50250 "Purchase Indent Header"
// {
//     Caption = 'Purchase Indent';
//     DataClassification = CustomerContent;
//     LookupPageId = "Purchase Indent List";
//     DrillDownPageId = "Purchase Indent List";

//     fields
//     {
//         field(1; "No."; Code[20])
//         {
//             Caption = 'Indent No.';
//             Editable = false;
//         }
//         field(2; "Request Date"; Date)
//         {
//             Caption = 'Request Date';
//         }
//         field(3; "Requested By"; Code[50])
//         {
//             Caption = 'Requested By';
//             Editable = false;
//         }
//         field(4; "Location Code"; Code[10])
//         {
//             Caption = 'Location Code';
//             TableRelation = Location.Code;
//         }
//         field(5; Description; Text[100])
//         {
//             Caption = 'Description';
//         }
//         field(6; Status; Enum "Purchase Indent Status")
//         {
//             Caption = 'Status';
//             Editable = false;
//         }
//     }

//     keys
//     {
//         key(PK; "No.")
//         {
//             Clustered = true;
//         }
//     }
// }

table 50250 "Purchase Indent Header"
{
    Caption = 'Purchase Indent';
    DataClassification = CustomerContent;
    LookupPageId = "Purchase Indent List";
    DrillDownPageId = "Purchase Indent List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Indent No.';
            Editable = false;
        }
        field(2; "Request Date"; Date)
        {
            Caption = 'Request Date';
        }
        field(3; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            Editable = false;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; Status; Enum "Purchase Indent Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series".Code;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
        IndentNoSeries: Code[20];
    begin
        if "No." = '' then begin
            IndentNoSeries := 'PURINDENT';

            "No." := NoSeries.GetNextNo(
                IndentNoSeries, WorkDate());

            "No. Series" := IndentNoSeries;
        end;

        if "Request Date" = 0D then
            "Request Date" := WorkDate();

        if "Requested By" = '' then
            "Requested By" := CopyStr(UserId(), 1, MaxStrLen("Requested By"));

        // if Status = Status::" " then
        //     Status := Status::Open;
        Status := Status::Open;
    end;
}