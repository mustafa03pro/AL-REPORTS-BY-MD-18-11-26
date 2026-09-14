pageextension 50208 "RequestsToApproveExt" extends "Requests to Approve"
{
    layout
    {
        addafter("Due Date")
        {
            field("Date-Time Sent for Approval"; Rec."Date-Time Sent for Approval")
            {
                ApplicationArea = All;
                Caption = 'Date-Time Sent for Approval';
                ToolTip = 'Specifies the exact date and time the approval request was submitted.';
            }
            field("Last Date-Time Modified"; Rec."Last Date-Time Modified")
            {
                ApplicationArea = All;
                Caption = 'Approved/Modified Date-Time';
                ToolTip = 'Specifies the exact date and time the approval status was last updated.';
            }
        }
    }
}