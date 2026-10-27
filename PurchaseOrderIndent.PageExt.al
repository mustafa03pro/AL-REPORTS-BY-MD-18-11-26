
pageextension 50255 "Purchase Order Indent Ext" extends "Purchase Order"
{
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("Purchase Indent No."; Rec."Purchase Indent No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Shows the Purchase Indent from which this Purchase Order was created.';
            }
        }
    }
}
