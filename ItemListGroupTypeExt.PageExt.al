pageextension 50240 "ItemListGroupTypeExt" extends "Item List"
{
    layout
    {
        // Adds Group Type right after the Description column
        addafter(Description)
        {
            field("Group Type"; Rec."Group Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Group Type for the item.';
                Visible = true;
            }
        }
    }
}