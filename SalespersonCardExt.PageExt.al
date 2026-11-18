
pageextension 50176 "Salesperson Sales Target Ext"
    extends "Salesperson/Purchaser Card"
{
    actions
    {
        addlast(Processing)
        {
            action(SalespersonSalesTargets)
            {
                Caption = 'Sales Targets';
                ApplicationArea = All;
                Image = Sales;
                Promoted = true;
                PromotedCategory = Process;

                RunObject = page "Salesperson Sales Target List";

                RunPageLink =
                    "Salesperson Code" = field(Code);

                ToolTip =
                    'View and manage sales targets for this salesperson.';
            }
        }
    }
}
