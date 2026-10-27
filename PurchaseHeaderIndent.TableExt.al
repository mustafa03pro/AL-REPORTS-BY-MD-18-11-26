
tableextension 50254 "Purchase Header Indent Ext" extends "Purchase Header"
{
    fields
    {
        field(50254; "Purchase Indent No."; Code[20])
        {
            Caption = 'Purchase Indent No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Indent Header"."No.";
            Editable = false;
        }
    }
}
