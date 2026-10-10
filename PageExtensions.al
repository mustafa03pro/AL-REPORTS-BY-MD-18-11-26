// // --- SALES ORDER & SALES INVOICE ---
// pageextension 50227 "SalesOrderRateExt" extends "Sales Order"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// pageextension 50228 "SalesInvoiceRateExt" extends "Sales Invoice"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// // --- PURCHASE ORDER & PURCHASE INVOICE ---
// pageextension 50229 "PurchOrderRateExt" extends "Purchase Order"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// pageextension 50230 "PurchInvoiceRateExt" extends "Purchase Invoice"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// // --- GENERAL JOURNAL, CASH RECEIPTS, PAYMENT JOURNALS ---
// pageextension 50231 "GeneralJournalRateExt" extends "General Journal"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// pageextension 50232 "CashReceiptJournalRateExt" extends "Cash Receipt Journal"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// pageextension 50233 "PaymentJournalRateExt" extends "Payment Journal"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }

// // --- ITEM JOURNAL ---
// pageextension 50234 "ItemJournalRateExt" extends "Item Journal"
// {
//     layout
//     {
//         addafter("Unit Amount")
//         {
//             field("Custom Exch. Rate"; Rec."Custom Exch. Rate")
//             {
//                 ApplicationArea = All;
//                 Visible = IsTargetCompany;
//                 Editable = IsTargetCompany;
//                 ToolTip = 'Specifies custom exchange rate for this transaction.';
//             }
//         }
//     }

//     var
//         IsTargetCompany: Boolean;

//     trigger OnOpenPage()
//     begin
//         IsTargetCompany := CompanyName() = 'CIFEAC_BACKUP_21_08_2026';
//     end;
// }