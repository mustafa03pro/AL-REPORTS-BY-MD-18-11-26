
// permissionset 50306 "SALESTARGET ADMIN"
// {
//     Caption = 'Sales Target Administrator';
//     Assignable = true;

//     Permissions =
//         tabledata "Salesperson Sales Target Head" = RIMD,


//         table "Salesperson Sales Target Head" = X,


//         page "Salesperson Sales Target List" = X,
//         page "Salesperson Sales Target Card" = X,
//         page "Salesperson Sales Target Lines" = X,

//         tabledata "Salesperson/Purchaser" = R,
//         tabledata "Inventory Posting Group" = R;
// }


permissionset 50306 "SALESTARGET ADMIN"
{
    Caption = 'Sales Target Administrator';
    Assignable = true;

    Permissions =
        // Sales Target Header
        tabledata "Salesperson Sales Target Head" = RIMD,
        table "Salesperson Sales Target Head" = X,

        // Sales Target Lines - MISSING PERMISSION
        tabledata "Salesperson Sales Target Line" = RIMD,
        table "Salesperson Sales Target Line" = X,

        // Sales Target Pages
        page "Salesperson Sales Target List" = X,
        page "Salesperson Sales Target Card" = X,
        page "Salesperson Sales Target Lines" = X,

        // Standard Business Central tables
        tabledata "Salesperson/Purchaser" = R,
        tabledata "Inventory Posting Group" = R;
}
