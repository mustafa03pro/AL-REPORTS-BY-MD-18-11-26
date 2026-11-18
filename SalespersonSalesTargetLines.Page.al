
page 50303 "Salesperson Sales Target Lines"
{
    PageType = ListPart;
    SourceTable = "Salesperson Sales Target Line";

    Caption = 'Inventory Posting Group Targets';
    ApplicationArea = All;

    AutoSplitKey = true;
    DelayedInsert = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Inventory Posting Group";
                Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                }

                field("Target Quantity"; Rec."Target Quantity")
                {
                    ApplicationArea = All;
                }

                field("Target Revenue"; Rec."Target Revenue")
                {
                    ApplicationArea = All;
                }

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
