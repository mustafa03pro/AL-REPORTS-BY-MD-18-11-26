tableextension 50230 "Transfer Header Requester Ext"
    extends "Transfer Header"
{
    fields
    {
        field(50230; "Requested By User ID"; Code[50])
        {
            Caption = 'Requested By User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }
}