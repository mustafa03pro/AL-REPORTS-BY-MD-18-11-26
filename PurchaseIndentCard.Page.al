page 50251 "Purchase Indent Card"
{
    Caption = 'Purchase Indent';
    PageType = Document;
    SourceTable = "Purchase Indent Header";
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

            }
            part(IndentLines; "Purchase Indent Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Indent No." = field("No.");
            }
        }
    }
}