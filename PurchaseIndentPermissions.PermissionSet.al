permissionset 50257 "PUR INDENT STORE"
{
    Caption = 'Purchase Indent - Store Manager';
    Assignable = true;

    Permissions =
        tabledata "Purchase Indent Header" = RIM,
        tabledata "Purchase Indent Line" = RIM,
        tabledata "Purchase Indent History" = RIM,
        //tabledata "Purchase Indent History" = R,
        page "Purchase Indent List" = X,
        page "Purchase Indent Card" = X,
        page "Purchase Indent Lines" = X,
        page "Purchase Indent History" = X,
        codeunit "Indent to Purchase Order" = X;
}