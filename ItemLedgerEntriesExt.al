pageextension 50211 "Item Ledger Entries Ext" extends "Item Ledger Entries"
{
    layout
    {
        addafter("Entry No.")
        {
            field("Created By User"; GetCreatedByUser())
            {
                ApplicationArea = All;
                Caption = 'Created By User';
                ToolTip = 'Specifies the Business Central user who created this item ledger entry.';
                Editable = false;
            }
        }
    }

    local procedure GetCreatedByUser(): Code[50]
    var
        User: Record User;
    begin
        if User.Get(Rec.SystemCreatedBy) then
            exit(User."User Name");

        exit('');
    end;
}