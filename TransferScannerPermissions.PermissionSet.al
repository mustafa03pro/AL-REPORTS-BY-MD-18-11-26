
permissionset 50261 "TRANSFER SCANNER"
{
    Caption = 'Raw Material Transfer Scanner';
    Assignable = true;

    Permissions =
        tabledata "Transfer Scan Buffer" = RIMD,
        tabledata "Transfer Header" = RIMD,
        tabledata "Transfer Line" = RIMD,
        page "Raw Material Transfer Scanner" = X,
        page "Transfer Scan Lines" = X;
}
