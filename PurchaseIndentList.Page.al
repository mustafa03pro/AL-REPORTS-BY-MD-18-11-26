page 50250 "Purchase Indent List"
{
    Caption = 'Purchase Indent List';
    PageType = List;
    SourceTable = "Purchase Indent Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Purchase Indent Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewIndent)
            {
                Caption = 'New Purchase Indent';
                ApplicationArea = All;
                Image = New;

                trigger OnAction()
                var
                    IndentHeader: Record "Purchase Indent Header";
                begin
                    IndentHeader.Init();
                    IndentHeader.Insert(true);
                    Page.Run(Page::"Purchase Indent Card", IndentHeader);
                end;
            }
        }
    }
}