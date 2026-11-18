
page 50304 "Salesperson Sales Target Card"
{
    PageType = Document;

    SourceTable = "Salesperson Sales Target Head";

    Caption = 'Salesperson Sales Target';

    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Target Details';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
                    ShowMandatory = true;
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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

            part(TargetLines; "Salesperson Sales Target Lines")
            {
                ApplicationArea = All;

                SubPageLink =
                    "Target No." = field("No.");

                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteCompleteTarget)
            {
                Caption = 'Delete Complete Target';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if not Confirm(
                        'Delete this complete target and all its lines?')
                    then
                        exit;

                    Rec.Delete(true);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Rec."No." <> '' then begin
            Rec.TestField("Salesperson Code");
            Rec.TestField("Start Date");
            Rec.TestField("End Date");

            if Rec."Start Date" > Rec."End Date" then
                Error('Start Date cannot exceed End Date.');
        end;

        exit(true);
    end;
}
