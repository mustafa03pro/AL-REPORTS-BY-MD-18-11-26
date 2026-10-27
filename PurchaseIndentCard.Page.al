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
        area(FactBoxes)
        {
            part(IndentAttachments; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink =
            "Table ID" = const(Database::"Purchase Indent Header"),
            "No." = field("No.");
            }
        }


    }

    actions
    {
        area(Processing)
        {
            action(ViewIndentHistory)
            {
                Caption = 'Document History';
                ApplicationArea = All;
                Image = History;
                ToolTip = 'View purchase orders created from this indent.';

                trigger OnAction()
                var
                    IndentHistory: Record "Purchase Indent History";
                begin
                    IndentHistory.SetRange(
                        "Indent No.", Rec."No.");

                    Page.Run(
                        Page::"Purchase Indent History",
                        IndentHistory);
                end;
            }
        }
    }
}