
page 50305 "Salesperson Sales Target List"
{
    PageType = List;

    SourceTable = "Salesperson Sales Target Head";

    Caption = 'Salesperson Sales Targets';

    ApplicationArea = All;
    UsageCategory = Lists;

    CardPageId = "Salesperson Sales Target Card";

    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Targets)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }

                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Period Type"; Rec."Period Type")
                {
                    ApplicationArea = All;
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }

                field("Created By"; Rec."Created By")
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
            action(NewTarget)
            {
                Caption = 'New Salesperson Target';
                ApplicationArea = All;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    TargetHeader: Record "Salesperson Sales Target Head";
                    SalespersonCode: Code[20];
                begin
                    SalespersonCode :=
                        Rec.GetFilter("Salesperson Code");

                    TargetHeader.Init();

                    if SalespersonCode <> '' then
                        TargetHeader.Validate(
                            "Salesperson Code",
                            SalespersonCode);

                    if Page.RunModal(
                        Page::"Salesperson Sales Target Card",
                        TargetHeader) = Action::OK
                    then
                        CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        SalespersonCode: Code[20];
    begin
        SalespersonCode :=
            Rec.GetFilter("Salesperson Code");

        if SalespersonCode <> '' then
            Rec.Validate(
                "Salesperson Code",
                SalespersonCode);
    end;
}
