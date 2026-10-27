
permissionset 50260 "DIRECT CONSUMPTION"
{
    Caption = 'Direct Consumption Scanner';
    Assignable = true;

    Permissions =
        tabledata "Direct Consumption Scan Line" = RIMD,
        tabledata "Transfer Scan Buffer" = RIMD,
        page "Direct Consumption Scanner" = X,
        page "Direct Consumption Scan Lines" = X,
        page "Direct Consumption Preview" = X;
}
