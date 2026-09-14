// pageextension 50209 "TransferOrderAttachmentExt" extends "Transfer Order"
// {
//     layout
//     {
//         addfirst(factboxes)
//         {
//             part(DocFiles; "Doc. Attachment List Factbox")
//             {
//                 ApplicationArea = All;
//                 SubPageLink = "Table ID" = const(5740),
//                               "No." = field("No.");
//             }
//         }
//     }
// }