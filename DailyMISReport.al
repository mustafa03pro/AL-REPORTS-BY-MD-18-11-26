// report 50212 "Daily MIS Report"
// {
//     UsageCategory = ReportsAndAnalysis;
//     ApplicationArea = All;
//     Caption = 'Daily MIS Report';

//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem(Integer; Integer)
//         {
//             DataItemTableView = where(Number = const(1));

//             trigger OnAfterGetRecord()
//             begin
//                 if ReportDate = 0D then
//                     Error('Please enter Report Date.');

//                 CreateExcelReport();
//             end;
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 group(Period)
//                 {
//                     Caption = 'Report Period';

//                     field(ReportDateField; ReportDate)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Report Date';
//                     }
//                 }
//             }
//         }

//         trigger OnOpenPage()
//         begin
//             if ReportDate = 0D then
//                 ReportDate := WorkDate();
//         end;
//     }

//     var
//         ExcelBuffer: Record "Excel Buffer" temporary;

//         ReportDate: Date;

//         Item: Record Item;
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         ValueEntry: Record "Value Entry";

//         SalesInvoiceHeader: Record "Sales Invoice Header";
//         SalesInvoiceLine: Record "Sales Invoice Line";

//         PurchInvoiceHeader: Record "Purch. Inv. Header";
//         PurchInvoiceLine: Record "Purch. Inv. Line";

//         CustomerLedgerEntry: Record "Cust. Ledger Entry";
//         VendorLedgerEntry: Record "Vendor Ledger Entry";

//         BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
//         BankAccount: Record "Bank Account";
//         BankAccountPostingGroup: Record "Bank Account Posting Group";

//         GLEntry: Record "G/L Entry";
//         GLAccount: Record "G/L Account";

//         Customer: Record Customer;
//         Vendor: Record Vendor;

//         Salesperson: Record "Salesperson/Purchaser";

//         ItemUnitOfMeasure: Record "Item Unit of Measure";

//         CurrentSheet: Text[250];

//         // =====================================================
//         // SALES
//         // =====================================================

//         SalesMT: Decimal;
//         SalesAmount: Decimal;
//         SalesVAT: Decimal;
//         SalesRatePerMT: Decimal;
//         FreightRecoverable: Decimal;
//         LineMT: Decimal;

//         // =====================================================
//         // STOCK
//         // =====================================================

//         OpeningQty: Decimal;
//         OpeningMT: Decimal;

//         PurchaseQty: Decimal;
//         PurchaseMT: Decimal;

//         ProductionQty: Decimal;
//         ProductionMT: Decimal;

//         SalesStockQty: Decimal;
//         SalesStockMT: Decimal;

//         ConsumptionQty: Decimal;
//         ConsumptionMT: Decimal;

//         TransferInQty: Decimal;
//         TransferInMT: Decimal;

//         TransferOutQty: Decimal;
//         TransferOutMT: Decimal;

//         PositiveAdjustmentQty: Decimal;
//         NegativeAdjustmentQty: Decimal;

//         ClosingQty: Decimal;
//         ClosingMT: Decimal;

//         // =====================================================
//         // CASH / BANK
//         // =====================================================

//         BankReceipt: Decimal;
//         BankPayment: Decimal;

//         CashReceipt: Decimal;
//         CashPayment: Decimal;

//         // =====================================================
//         // PAYMENTS
//         // =====================================================

//         PaymentAmount: Decimal;
//         PaymentAccountNo: Code[20];
//         ExpenseAccountNo: Code[20];

//         CustomerPaymentAmount: Decimal;

//         // =====================================================
//         // FG POSTING GROUPS
//         // =====================================================

//         FGPostingGroups: Label
//             'FG CHANNELS|FG I BEAM|FG ANGLES|FG TMT BARS FE-500|FG - BINDING WIRE|TMT BARS RANDOMS|RANDOM|FG-STRUCTURES RANDOM';

//         // =====================================================
//         // PERFORMANCE CACHE / AGGREGATION
//         // =====================================================

//         FGItemCache: Dictionary of [Code[20], Boolean];
//         ItemBaseMTCache: Dictionary of [Code[20], Boolean];
//         ItemNetWeightCache: Dictionary of [Code[20], Decimal];

//         StockOpeningQtyByItem: Dictionary of [Code[20], Decimal];
//         StockOpeningMTByItem: Dictionary of [Code[20], Decimal];

//         PurchaseQtyByItem: Dictionary of [Code[20], Decimal];
//         PurchaseMTByItem: Dictionary of [Code[20], Decimal];

//         ProductionQtyByItem: Dictionary of [Code[20], Decimal];
//         ProductionMTByItem: Dictionary of [Code[20], Decimal];

//         SalesQtyByItem: Dictionary of [Code[20], Decimal];
//         SalesMTByItem: Dictionary of [Code[20], Decimal];
//         SalesAmountByItem: Dictionary of [Code[20], Decimal];

//         ConsumptionQtyByItem: Dictionary of [Code[20], Decimal];
//         ConsumptionMTByItem: Dictionary of [Code[20], Decimal];

//         TransferInQtyByItem: Dictionary of [Code[20], Decimal];
//         TransferInMTByItem: Dictionary of [Code[20], Decimal];

//         TransferOutQtyByItem: Dictionary of [Code[20], Decimal];
//         TransferOutMTByItem: Dictionary of [Code[20], Decimal];

//         PositiveAdjByItem: Dictionary of [Code[20], Decimal];
//         NegativeAdjByItem: Dictionary of [Code[20], Decimal];

//         StockClosingQtyByItem: Dictionary of [Code[20], Decimal];
//         StockClosingMTByItem: Dictionary of [Code[20], Decimal];


//     // =========================================================
//     // MAIN REPORT
//     // =========================================================

//     local procedure CreateExcelReport()
//     begin
//         // =====================================================
//         // STEP 1 - Prepare the data once
//         // =====================================================
//         BuildFGItemCache();
//         BuildItemLedgerAggregates();
//         BuildSalesValueAggregates();

//         // =====================================================
//         // STEP 2 - Create the workbook once
//         // =====================================================
//         ExcelBuffer.Reset();
//         ExcelBuffer.DeleteAll();
//         ExcelBuffer.ClearNewRow();

//         ExcelBuffer.CreateNewBook('MIS Summary');
//         ExcelBuffer.ClearNewRow();

//         // First worksheet
//         CreateMISSummarySheet();

//         // Remaining worksheets
//         CreateSalesDetailSheet();
//         CreateSalesByItemSheet();
//         CreatePurchaseSheet();
//         CreateCashReceiptSheet();
//         CreateBankTransactionSheet();
//         CreateGLTransactionSheet();
//         CreateItemStockSheet();
//         CreateCustomerPaymentSheet();
//         CreateVendorPaymentSheet();

//         // =====================================================
//         // STEP 3 - Close and open workbook
//         // =====================================================
//         ExcelBuffer.CloseBook();

//         ExcelBuffer.SetFriendlyFilename(
//             StrSubstNo(
//                 'Daily MIS Report - %1',
//                 Format(ReportDate, 0, '<Year4><Month,2><Day,2>')));

//         ExcelBuffer.OpenExcel();
//     end;

//     // =========================================================
//     // PREPARE NEW SHEET
//     // =========================================================

//     local procedure PrepareNewSheet(
//         SheetName: Text[250])
//     begin
//         ExcelBuffer.Reset();
//         ExcelBuffer.DeleteAll();
//         ExcelBuffer.ClearNewRow();

//         ExcelBuffer.SelectOrAddSheet(
//             SheetName);

//         ExcelBuffer.ClearNewRow();
//     end;


//     // =========================================================
//     // FINISH CURRENT SHEET
//     // =========================================================

//     local procedure FinishSheet(
//         SheetName: Text[250])
//     begin
//         // Do not clear the buffer here.
//         // The next PrepareNewSheet call clears it before selecting
//         // the next worksheet.
//         ExcelBuffer.WriteSheet(
//             SheetName,
//             CompanyName,
//             UserId);
//     end;


//     // =========================================================
//     // MIS SUMMARY
//     // =========================================================

//     local procedure CreateMISSummarySheet()
//     begin
//         CurrentSheet := 'MIS Summary';

//         // CreateNewBook('MIS Summary') already created the first worksheet.
//         // Do not call SelectOrAddSheet for the first worksheet.

//         ExcelBuffer.ClearNewRow();

//         AddTitle(
//             'DAILY MIS REPORT');

//         ExcelBuffer.NewRow();

//         AddText(
//             'Report Date');

//         AddDate(
//             ReportDate);

//         ExcelBuffer.NewRow();

//         AddText(
//             'Company');

//         AddText(
//             CompanyName);

//         ExcelBuffer.NewRow();

//         AddText(
//             'Finished Goods Inventory Posting Groups');

//         ExcelBuffer.NewRow();
//         AddText('FG CHANNELS');

//         ExcelBuffer.NewRow();
//         AddText('FG I BEAM');

//         ExcelBuffer.NewRow();
//         AddText('FG ANGLES');

//         ExcelBuffer.NewRow();
//         AddText('FG TMT BARS FE-500');

//         ExcelBuffer.NewRow();
//         AddText('FG - BINDING WIRE');

//         ExcelBuffer.NewRow();
//         AddText('TMT BARS RANDOMS');

//         ExcelBuffer.NewRow();
//         AddText('RANDOM');

//         ExcelBuffer.NewRow();
//         AddText('FG-STRUCTURES RANDOM');

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // SALES DETAIL
//     // =========================================================

//     local procedure CreateSalesDetailSheet()
//     begin
//         CurrentSheet := 'Sales Detail';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'SALES TRANSACTION DETAIL');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Document No.');
//         AddHeader('Lead');
//         AddHeader('Customer No.');
//         AddHeader('Buyer');
//         AddHeader('Item No.');
//         AddHeader('Item Description');
//         AddHeader('Inventory Posting Group');
//         AddHeader('Size');
//         AddHeader('Unit');
//         AddHeader('Quantity');
//         AddHeader('Unit Price');
//         AddHeader('Sale Value');
//         AddHeader('TVA');
//         AddHeader('MT');
//         AddHeader('Rate Per MT');
//         AddHeader('Freight Recoverable');
//         AddHeader('Location');

//         SalesInvoiceHeader.Reset();

//         SalesInvoiceHeader.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if SalesInvoiceHeader.FindSet() then
//             repeat

//                 SalesInvoiceLine.Reset();

//                 SalesInvoiceLine.SetRange(
//                     "Document No.",
//                     SalesInvoiceHeader."No.");

//                 SalesInvoiceLine.SetRange(
//                     Type,
//                     SalesInvoiceLine.Type::Item);

//                 if SalesInvoiceLine.FindSet() then
//                     repeat

//                         if IsFGItem(
//                             SalesInvoiceLine."No.")
//                         then begin

//                             SalesMT :=
//                                 GetSalesLineMT(
//                                     SalesInvoiceLine);

//                             if SalesMT <> 0 then
//                                 SalesRatePerMT :=
//                                     SalesInvoiceLine."Line Amount" /
//                                     SalesMT
//                             else
//                                 SalesRatePerMT := 0;

//                             SalesVAT :=
//                                 SalesInvoiceLine."Amount Including VAT" -
//                                 SalesInvoiceLine.Amount;

//                             FreightRecoverable :=
//                                 GetFreightRecoverable(
//                                     SalesInvoiceLine);

//                             ExcelBuffer.NewRow();

//                             AddDate(
//                                 SalesInvoiceHeader."Posting Date");

//                             AddText(
//                                 SalesInvoiceHeader."No.");

//                             AddText(
//                                 GetLeadName(
//                                     SalesInvoiceHeader."Salesperson Code"));

//                             AddText(
//                                 SalesInvoiceHeader."Sell-to Customer No.");

//                             AddText(
//                                 SalesInvoiceHeader."Bill-to Name");

//                             AddText(
//                                 SalesInvoiceLine."No.");

//                             AddText(
//                                 SalesInvoiceLine.Description);

//                             AddText(
//                                 GetInventoryPostingGroup(
//                                     SalesInvoiceLine."No."));

//                             AddText(
//                                 GetItemSize(
//                                     SalesInvoiceLine."No."));

//                             AddText(
//                                 SalesInvoiceLine."Unit of Measure Code");

//                             AddDecimal(
//                                 SalesInvoiceLine.Quantity);

//                             AddDecimal(
//                                 SalesInvoiceLine."Unit Price");

//                             AddDecimal(
//                                 SalesInvoiceLine."Line Amount");

//                             AddDecimal(
//                                 SalesVAT);

//                             AddDecimal(
//                                 SalesMT);

//                             AddDecimal(
//                                 SalesRatePerMT);

//                             AddDecimal(
//                                 FreightRecoverable);

//                             AddText(
//                                 SalesInvoiceLine."Location Code");
//                         end;

//                     until SalesInvoiceLine.Next() = 0;

//             until SalesInvoiceHeader.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // SALES BY ITEM
//     // =========================================================

//     local procedure CreateSalesByItemSheet()
//     begin
//         CurrentSheet := 'Sales by Item';

//         PrepareNewSheet(CurrentSheet);

//         AddTitle('FG SALES - ITEM WISE');

//         ExcelBuffer.NewRow();

//         AddHeader('Item No.');
//         AddHeader('Description');
//         AddHeader('Inventory Posting Group');
//         AddHeader('Base Unit');
//         AddHeader('Sales Qty');
//         AddHeader('Sales MT');
//         AddHeader('Sales Amount');
//         AddHeader('Average Rate / MT');

//         Item.Reset();
//         Item.SetFilter("Inventory Posting Group", FGPostingGroups);

//         if Item.FindSet() then
//             repeat
//                 SalesStockQty := GetDictDecimal(SalesQtyByItem, Item."No.");
//                 SalesStockMT := GetDictDecimal(SalesMTByItem, Item."No.");
//                 SalesAmount := GetDictDecimal(SalesAmountByItem, Item."No.");

//                 if (SalesStockQty <> 0) or (SalesAmount <> 0) then begin
//                     ExcelBuffer.NewRow();

//                     AddText(Item."No.");
//                     AddText(Item.Description);
//                     AddText(Item."Inventory Posting Group");
//                     AddText(Item."Base Unit of Measure");
//                     AddDecimal(SalesStockQty);
//                     AddDecimal(SalesStockMT);
//                     AddDecimal(SalesAmount);

//                     if SalesStockMT <> 0 then
//                         AddDecimal(SalesAmount / SalesStockMT)
//                     else
//                         AddDecimal(0);
//                 end;
//             until Item.Next() = 0;

//         FinishSheet(CurrentSheet);
//     end;

//     // =========================================================
//     // PURCHASES
//     // =========================================================

//     local procedure CreatePurchaseSheet()
//     begin
//         CurrentSheet := 'Purchases';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'FG PURCHASE TRANSACTIONS');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Document No.');
//         AddHeader('Vendor No.');
//         AddHeader('Vendor');
//         AddHeader('Item No.');
//         AddHeader('Description');
//         AddHeader('Inventory Posting Group');
//         AddHeader('Unit');
//         AddHeader('Quantity');
//         AddHeader('Unit Cost');
//         AddHeader('Amount');
//         AddHeader('MT');
//         AddHeader('Location');

//         PurchInvoiceHeader.Reset();

//         PurchInvoiceHeader.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if PurchInvoiceHeader.FindSet() then
//             repeat

//                 PurchInvoiceLine.Reset();

//                 PurchInvoiceLine.SetRange(
//                     "Document No.",
//                     PurchInvoiceHeader."No.");

//                 PurchInvoiceLine.SetRange(
//                     Type,
//                     PurchInvoiceLine.Type::Item);

//                 if PurchInvoiceLine.FindSet() then
//                     repeat

//                         if IsFGItem(
//                             PurchInvoiceLine."No.")
//                         then begin

//                             LineMT :=
//                                 GetPurchaseLineMT(
//                                     PurchInvoiceLine);

//                             ExcelBuffer.NewRow();

//                             AddDate(
//                                 PurchInvoiceHeader."Posting Date");

//                             AddText(
//                                 PurchInvoiceHeader."No.");

//                             AddText(
//                                 PurchInvoiceHeader."Buy-from Vendor No.");

//                             AddText(
//                                 PurchInvoiceHeader."Buy-from Vendor Name");

//                             AddText(
//                                 PurchInvoiceLine."No.");

//                             AddText(
//                                 PurchInvoiceLine.Description);

//                             AddText(
//                                 GetInventoryPostingGroup(
//                                     PurchInvoiceLine."No."));

//                             AddText(
//                                 PurchInvoiceLine."Unit of Measure Code");

//                             AddDecimal(
//                                 PurchInvoiceLine.Quantity);

//                             AddDecimal(
//                                 PurchInvoiceLine."Direct Unit Cost");

//                             AddDecimal(
//                                 PurchInvoiceLine."Line Amount");

//                             AddDecimal(
//                                 LineMT);

//                             AddText(
//                                 PurchInvoiceLine."Location Code");
//                         end;

//                     until PurchInvoiceLine.Next() = 0;

//             until PurchInvoiceHeader.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // CASH RECEIPTS / PAYMENTS
//     // =========================================================

//     local procedure CreateCashReceiptSheet()
//     var
//         CashGLEntry: Record "G/L Entry";
//     begin
//         CurrentSheet := 'Cash Receipts';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'CASH RECEIPT / PAYMENT DETAIL');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Document No.');
//         AddHeader('G/L Account');
//         AddHeader('Account Name');
//         AddHeader('Description');
//         AddHeader('Customer No.');
//         AddHeader('Customer');
//         AddHeader('Receipt');
//         AddHeader('Payment');
//         AddHeader('Net Amount');
//         AddHeader('User ID');
//         AddHeader('Source Code');

//         CashGLEntry.Reset();

//         CashGLEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if CashGLEntry.FindSet() then
//             repeat

//                 if IsCashGLAccount(
//                     CashGLEntry."G/L Account No.")
//                 then begin

//                     CashReceipt := 0;
//                     CashPayment := 0;

//                     if CashGLEntry."Debit Amount" <> 0 then
//                         CashReceipt :=
//                             CashGLEntry."Debit Amount";

//                     if CashGLEntry."Credit Amount" <> 0 then
//                         CashPayment :=
//                             CashGLEntry."Credit Amount";

//                     ExcelBuffer.NewRow();

//                     AddDate(
//                         CashGLEntry."Posting Date");

//                     AddText(
//                         CashGLEntry."Document No.");

//                     AddText(
//                         CashGLEntry."G/L Account No.");

//                     AddText(
//                         GetGLAccountName(
//                             CashGLEntry."G/L Account No."));

//                     AddText(
//                         CashGLEntry.Description);

//                     AddText(
//                         GetCustomerNoByDocument(
//                             CashGLEntry."Document No.",
//                             CashGLEntry."Posting Date"));

//                     AddText(
//                         GetCustomerNameByDocument(
//                             CashGLEntry."Document No.",
//                             CashGLEntry."Posting Date"));

//                     AddDecimal(
//                         CashReceipt);

//                     AddDecimal(
//                         CashPayment);

//                     AddDecimal(
//                         CashGLEntry.Amount);

//                     AddText(
//                         CashGLEntry."User ID");

//                     AddText(
//                         CashGLEntry."Source Code");
//                 end;

//             until CashGLEntry.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // BANK TRANSACTIONS
//     // =========================================================

//     local procedure CreateBankTransactionSheet()
//     var
//         BankGLEntry: Record "G/L Entry";
//     begin
//         CurrentSheet := 'Bank Transactions';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'BANK TRANSACTIONS');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Bank Account');
//         AddHeader('Bank Name');
//         AddHeader('Document No.');
//         AddHeader('Description');
//         AddHeader('Receipt');
//         AddHeader('Payment');
//         AddHeader('Net Amount');
//         AddHeader('Currency');
//         AddHeader('External Document No.');
//         AddHeader('User ID');
//         AddHeader('Source');

//         // -----------------------------------------------------
//         // Standard Bank Account Ledger Entries
//         // -----------------------------------------------------

//         BankAccountLedgerEntry.Reset();

//         BankAccountLedgerEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if BankAccountLedgerEntry.FindSet() then
//             repeat

//                 BankReceipt := 0;
//                 BankPayment := 0;

//                 if BankAccountLedgerEntry.Amount > 0 then
//                     BankReceipt :=
//                         BankAccountLedgerEntry.Amount
//                 else
//                     BankPayment :=
//                         Abs(
//                             BankAccountLedgerEntry.Amount);

//                 ExcelBuffer.NewRow();

//                 AddDate(
//                     BankAccountLedgerEntry."Posting Date");

//                 AddText(
//                     BankAccountLedgerEntry."Bank Account No.");

//                 AddText(
//                     GetBankName(
//                         BankAccountLedgerEntry."Bank Account No."));

//                 AddText(
//                     BankAccountLedgerEntry."Document No.");

//                 AddText(
//                     BankAccountLedgerEntry.Description);

//                 AddDecimal(
//                     BankReceipt);

//                 AddDecimal(
//                     BankPayment);

//                 AddDecimal(
//                     BankAccountLedgerEntry.Amount);

//                 AddText(
//                     BankAccountLedgerEntry."Currency Code");

//                 AddText(
//                     BankAccountLedgerEntry."External Document No.");

//                 AddText('');

//                 AddText(
//                     'Bank Account Ledger Entry');

//             until BankAccountLedgerEntry.Next() = 0;


//         // -----------------------------------------------------
//         // Bank G/L Entries
//         // -----------------------------------------------------

//         BankGLEntry.Reset();

//         BankGLEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if BankGLEntry.FindSet() then
//             repeat

//                 if IsBankGLAccount(
//                     BankGLEntry."G/L Account No.")
//                 then begin

//                     BankReceipt := 0;
//                     BankPayment := 0;

//                     if BankGLEntry."Debit Amount" <> 0 then
//                         BankReceipt :=
//                             BankGLEntry."Debit Amount";

//                     if BankGLEntry."Credit Amount" <> 0 then
//                         BankPayment :=
//                             BankGLEntry."Credit Amount";

//                     ExcelBuffer.NewRow();

//                     AddDate(
//                         BankGLEntry."Posting Date");

//                     AddText(
//                         BankGLEntry."G/L Account No.");

//                     AddText(
//                         GetGLAccountName(
//                             BankGLEntry."G/L Account No."));

//                     AddText(
//                         BankGLEntry."Document No.");

//                     AddText(
//                         BankGLEntry.Description);

//                     AddDecimal(
//                         BankReceipt);

//                     AddDecimal(
//                         BankPayment);

//                     AddDecimal(
//                         BankGLEntry.Amount);

//                     AddText('');

//                     AddText('');

//                     AddText(
//                         BankGLEntry."User ID");

//                     AddText(
//                         'G/L Entry');

//                 end;

//             until BankGLEntry.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // G/L TRANSACTIONS
//     // =========================================================

//     local procedure CreateGLTransactionSheet()
//     begin
//         CurrentSheet := 'G/L Transactions';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'DAILY G/L TRANSACTIONS');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Entry No.');
//         AddHeader('G/L Account');
//         AddHeader('Account Name');
//         AddHeader('Document No.');
//         AddHeader('Document Type');
//         AddHeader('Description');
//         AddHeader('Debit');
//         AddHeader('Credit');
//         AddHeader('Amount');
//         AddHeader('Source Code');
//         AddHeader('User ID');

//         GLEntry.Reset();

//         GLEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         if GLEntry.FindSet() then
//             repeat

//                 ExcelBuffer.NewRow();

//                 AddDate(
//                     GLEntry."Posting Date");

//                 AddInteger(
//                     GLEntry."Entry No.");

//                 AddText(
//                     GLEntry."G/L Account No.");

//                 AddText(
//                     GetGLAccountName(
//                         GLEntry."G/L Account No."));

//                 AddText(
//                     GLEntry."Document No.");

//                 AddText(
//                     Format(
//                         GLEntry."Document Type"));

//                 AddText(
//                     GLEntry.Description);

//                 AddDecimal(
//                     GLEntry."Debit Amount");

//                 AddDecimal(
//                     GLEntry."Credit Amount");

//                 AddDecimal(
//                     GLEntry.Amount);

//                 AddText(
//                     GLEntry."Source Code");

//                 AddText(
//                     GLEntry."User ID");

//             until GLEntry.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // ITEM STOCK
//     // =========================================================

//     local procedure CreateItemStockSheet()
//     begin
//         CurrentSheet := 'Item Stock';

//         PrepareNewSheet(CurrentSheet);

//         AddTitle('FG STOCK / PRODUCTION SUMMARY');

//         ExcelBuffer.NewRow();

//         AddHeader('Item No.');
//         AddHeader('Description');
//         AddHeader('Inventory Posting Group');
//         AddHeader('Base Unit');
//         AddHeader('Opening Qty');
//         AddHeader('Opening MT');
//         AddHeader('Purchase Qty');
//         AddHeader('Purchase MT');
//         AddHeader('Production Qty');
//         AddHeader('Production MT');
//         AddHeader('Transfer In');
//         AddHeader('Transfer In MT');
//         AddHeader('Sales Qty');
//         AddHeader('Sales MT');
//         AddHeader('Consumption Qty');
//         AddHeader('Consumption MT');
//         AddHeader('Transfer Out');
//         AddHeader('Transfer Out MT');
//         AddHeader('Positive Adj.');
//         AddHeader('Negative Adj.');
//         AddHeader('Closing Qty');
//         AddHeader('Closing MT');

//         Item.Reset();
//         Item.SetFilter("Inventory Posting Group", FGPostingGroups);

//         if Item.FindSet() then
//             repeat
//                 OpeningQty := GetDictDecimal(StockOpeningQtyByItem, Item."No.");
//                 OpeningMT := GetDictDecimal(StockOpeningMTByItem, Item."No.");

//                 PurchaseQty := GetDictDecimal(PurchaseQtyByItem, Item."No.");
//                 PurchaseMT := GetDictDecimal(PurchaseMTByItem, Item."No.");

//                 ProductionQty := GetDictDecimal(ProductionQtyByItem, Item."No.");
//                 ProductionMT := GetDictDecimal(ProductionMTByItem, Item."No.");

//                 TransferInQty := GetDictDecimal(TransferInQtyByItem, Item."No.");
//                 TransferInMT := GetDictDecimal(TransferInMTByItem, Item."No.");

//                 SalesStockQty := GetDictDecimal(SalesQtyByItem, Item."No.");
//                 SalesStockMT := GetDictDecimal(SalesMTByItem, Item."No.");

//                 ConsumptionQty := GetDictDecimal(ConsumptionQtyByItem, Item."No.");
//                 ConsumptionMT := GetDictDecimal(ConsumptionMTByItem, Item."No.");

//                 TransferOutQty := GetDictDecimal(TransferOutQtyByItem, Item."No.");
//                 TransferOutMT := GetDictDecimal(TransferOutMTByItem, Item."No.");

//                 PositiveAdjustmentQty := GetDictDecimal(PositiveAdjByItem, Item."No.");
//                 NegativeAdjustmentQty := GetDictDecimal(NegativeAdjByItem, Item."No.");

//                 ClosingQty := GetDictDecimal(StockClosingQtyByItem, Item."No.");
//                 ClosingMT := GetDictDecimal(StockClosingMTByItem, Item."No.");

//                 if (OpeningQty <> 0) or
//                    (PurchaseQty <> 0) or
//                    (ProductionQty <> 0) or
//                    (SalesStockQty <> 0) or
//                    (ConsumptionQty <> 0) or
//                    (TransferInQty <> 0) or
//                    (TransferOutQty <> 0) or
//                    (PositiveAdjustmentQty <> 0) or
//                    (NegativeAdjustmentQty <> 0) or
//                    (ClosingQty <> 0)
//                 then begin
//                     ExcelBuffer.NewRow();

//                     AddText(Item."No.");
//                     AddText(Item.Description);
//                     AddText(Item."Inventory Posting Group");
//                     AddText(Item."Base Unit of Measure");

//                     AddDecimal(OpeningQty);
//                     AddDecimal(OpeningMT);

//                     AddDecimal(PurchaseQty);
//                     AddDecimal(PurchaseMT);

//                     AddDecimal(ProductionQty);
//                     AddDecimal(ProductionMT);

//                     AddDecimal(TransferInQty);
//                     AddDecimal(TransferInMT);

//                     AddDecimal(SalesStockQty);
//                     AddDecimal(SalesStockMT);

//                     AddDecimal(ConsumptionQty);
//                     AddDecimal(ConsumptionMT);

//                     AddDecimal(TransferOutQty);
//                     AddDecimal(TransferOutMT);

//                     AddDecimal(PositiveAdjustmentQty);
//                     AddDecimal(NegativeAdjustmentQty);

//                     AddDecimal(ClosingQty);
//                     AddDecimal(ClosingMT);
//                 end;
//             until Item.Next() = 0;

//         FinishSheet(CurrentSheet);
//     end;

//     // =========================================================
//     // CUSTOMER PAYMENTS
//     // =========================================================

//     local procedure CreateCustomerPaymentSheet()
//     begin
//         CurrentSheet := 'Customer Payments';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'CUSTOMER PAYMENTS');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Document No.');
//         AddHeader('Customer No.');
//         AddHeader('Customer');
//         AddHeader('Description');
//         AddHeader('Amount');
//         AddHeader('Currency');
//         AddHeader('Bal. Account Type');
//         AddHeader('Bal. Account No.');

//         CustomerLedgerEntry.Reset();

//         CustomerLedgerEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         CustomerLedgerEntry.SetRange(
//             "Document Type",
//             CustomerLedgerEntry."Document Type"::Payment);

//         if CustomerLedgerEntry.FindSet() then
//             repeat

//                 CustomerPaymentAmount :=
//                     Abs(
//                         CustomerLedgerEntry.Amount);

//                 ExcelBuffer.NewRow();

//                 AddDate(
//                     CustomerLedgerEntry."Posting Date");

//                 AddText(
//                     CustomerLedgerEntry."Document No.");

//                 AddText(
//                     CustomerLedgerEntry."Customer No.");

//                 AddText(
//                     GetCustomerName(
//                         CustomerLedgerEntry."Customer No."));

//                 AddText(
//                     CustomerLedgerEntry.Description);

//                 AddDecimal(
//                     CustomerPaymentAmount);

//                 AddText(
//                     CustomerLedgerEntry."Currency Code");

//                 AddText(
//                     Format(
//                         CustomerLedgerEntry."Bal. Account Type"));

//                 AddText(
//                     CustomerLedgerEntry."Bal. Account No.");

//             until CustomerLedgerEntry.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // VENDOR PAYMENTS
//     // =========================================================

//     local procedure CreateVendorPaymentSheet()
//     begin
//         CurrentSheet := 'Vendor Payments';

//         PrepareNewSheet(
//             CurrentSheet);

//         AddTitle(
//             'VENDOR PAYMENTS');

//         ExcelBuffer.NewRow();

//         AddHeader('Posting Date');
//         AddHeader('Document No.');
//         AddHeader('Vendor No.');
//         AddHeader('Vendor');
//         AddHeader('Description');
//         AddHeader('Amount');
//         AddHeader('Currency');
//         AddHeader('Payment Account');
//         AddHeader('Payment Account Name');
//         AddHeader('Expense / G/L Account');
//         AddHeader('Expense Account Name');

//         VendorLedgerEntry.Reset();

//         VendorLedgerEntry.SetRange(
//             "Posting Date",
//             ReportDate,
//             ReportDate);

//         VendorLedgerEntry.SetRange(
//             "Document Type",
//             VendorLedgerEntry."Document Type"::Payment);

//         if VendorLedgerEntry.FindSet() then
//             repeat

//                 PaymentAmount :=
//                     GetVendorPaymentAmount(
//                         VendorLedgerEntry."Document No.",
//                         VendorLedgerEntry."Posting Date");

//                 PaymentAccountNo :=
//                     GetVendorPaymentAccount(
//                         VendorLedgerEntry."Document No.",
//                         VendorLedgerEntry."Posting Date");

//                 ExpenseAccountNo :=
//                     GetVendorExpenseAccount(
//                         VendorLedgerEntry."Document No.",
//                         VendorLedgerEntry."Posting Date");

//                 ExcelBuffer.NewRow();

//                 AddDate(
//                     VendorLedgerEntry."Posting Date");

//                 AddText(
//                     VendorLedgerEntry."Document No.");

//                 AddText(
//                     VendorLedgerEntry."Vendor No.");

//                 AddText(
//                     GetVendorName(
//                         VendorLedgerEntry."Vendor No."));

//                 AddText(
//                     VendorLedgerEntry.Description);

//                 AddDecimal(
//                     PaymentAmount);

//                 AddText(
//                     VendorLedgerEntry."Currency Code");

//                 AddText(
//                     PaymentAccountNo);

//                 AddText(
//                     GetGLAccountName(
//                         PaymentAccountNo));

//                 AddText(
//                     ExpenseAccountNo);

//                 AddText(
//                     GetGLAccountName(
//                         ExpenseAccountNo));

//             until VendorLedgerEntry.Next() = 0;

//         FinishSheet(
//             CurrentSheet);
//     end;


//     // =========================================================
//     // VENDOR PAYMENT AMOUNT
//     // =========================================================

//     local procedure GetVendorPaymentAmount(
//         DocumentNo: Code[20];
//         PostingDate: Date): Decimal
//     var
//         GLEntry2: Record "G/L Entry";
//         TotalAmount: Decimal;
//     begin
//         TotalAmount := 0;

//         GLEntry2.Reset();

//         GLEntry2.SetRange(
//             "Posting Date",
//             PostingDate,
//             PostingDate);

//         GLEntry2.SetRange(
//             "Document No.",
//             DocumentNo);

//         if GLEntry2.FindSet() then
//             repeat

//                 if IsCashOrBankGLAccount(
//                     GLEntry2."G/L Account No.")
//                 then
//                     if GLEntry2."Credit Amount" <> 0 then
//                         TotalAmount +=
//                             GLEntry2."Credit Amount";

//             until GLEntry2.Next() = 0;

//         exit(
//             TotalAmount);
//     end;


//     // =========================================================
//     // VENDOR PAYMENT ACCOUNT
//     // =========================================================

//     local procedure GetVendorPaymentAccount(
//         DocumentNo: Code[20];
//         PostingDate: Date): Code[20]
//     var
//         GLEntry2: Record "G/L Entry";
//     begin
//         GLEntry2.Reset();

//         GLEntry2.SetRange(
//             "Posting Date",
//             PostingDate,
//             PostingDate);

//         GLEntry2.SetRange(
//             "Document No.",
//             DocumentNo);

//         if GLEntry2.FindSet() then
//             repeat

//                 if IsCashOrBankGLAccount(
//                     GLEntry2."G/L Account No.")
//                 then
//                     if GLEntry2."Credit Amount" <> 0 then
//                         exit(
//                             GLEntry2."G/L Account No.");

//             until GLEntry2.Next() = 0;

//         exit('');
//     end;


//     // =========================================================
//     // VENDOR EXPENSE ACCOUNT
//     // =========================================================

//     local procedure GetVendorExpenseAccount(
//         DocumentNo: Code[20];
//         PostingDate: Date): Code[20]
//     var
//         GLEntry2: Record "G/L Entry";
//     begin
//         GLEntry2.Reset();

//         GLEntry2.SetRange(
//             "Posting Date",
//             PostingDate,
//             PostingDate);

//         GLEntry2.SetRange(
//             "Document No.",
//             DocumentNo);

//         if GLEntry2.FindSet() then
//             repeat

//                 if not IsCashOrBankGLAccount(
//                     GLEntry2."G/L Account No.")
//                 then
//                     if GLEntry2."Debit Amount" <> 0 then
//                         exit(
//                             GLEntry2."G/L Account No.");

//             until GLEntry2.Next() = 0;

//         exit('');
//     end;


//     // =========================================================
//     // CASH G/L ACCOUNT
//     // =========================================================

//     local procedure IsCashGLAccount(
//         GLAccountNo: Code[20]): Boolean
//     begin
//         // Your actual Cash account identified
//         // from the previous generated MIS:
//         //
//         // 20803 = Cash- Africa

//         if GLAccountNo = '20803' then
//             exit(true);

//         exit(false);
//     end;


//     // =========================================================
//     // CASH OR BANK
//     // =========================================================

//     local procedure IsCashOrBankGLAccount(
//         GLAccountNo: Code[20]): Boolean
//     begin
//         if IsCashGLAccount(
//             GLAccountNo)
//         then
//             exit(true);

//         if IsBankGLAccount(
//             GLAccountNo)
//         then
//             exit(true);

//         exit(false);
//     end;


//     // =========================================================
//     // BANK G/L ACCOUNT
//     // =========================================================

//     local procedure IsBankGLAccount(
//         GLAccountNo: Code[20]): Boolean
//     begin
//         BankAccountPostingGroup.Reset();

//         BankAccountPostingGroup.SetRange(
//             "G/L Account No.",
//             GLAccountNo);

//         if BankAccountPostingGroup.FindFirst() then
//             exit(true);

//         exit(false);
//     end;


//     // =========================================================
//     // FG ITEM CHECK
//     // =========================================================

//     local procedure IsFGItem(
//         ItemNo: Code[20]): Boolean
//     var
//         ItemCheck: Record Item;
//     begin
//         if ItemNo = '' then
//             exit(false);

//         if not ItemCheck.Get(
//             ItemNo)
//         then
//             exit(false);

//         exit(
//             IsFGPostingGroup(
//                 ItemCheck."Inventory Posting Group"));
//     end;


//     // =========================================================
//     // FG POSTING GROUP CHECK
//     // =========================================================

//     local procedure IsFGPostingGroup(
//         PostingGroup: Code[20]): Boolean
//     begin
//         case PostingGroup of

//             'FG CHANNELS',
//             'FG I BEAM',
//             'FG ANGLES',
//             'FG TMT BARS FE-500',
//             'FG - BINDING WIRE',
//             'TMT BARS RANDOMS',
//             'RANDOM',
//             'FG-STRUCTURES RANDOM':
//                 exit(true);

//         end;

//         exit(false);
//     end;


//     // =========================================================
//     // BUILD FG ITEM CACHE
//     // =========================================================

//     local procedure BuildFGItemCache()
//     var
//         ItemCache: Record Item;
//     begin
//         Clear(FGItemCache);
//         Clear(ItemBaseMTCache);
//         Clear(ItemNetWeightCache);

//         ItemCache.Reset();
//         ItemCache.SetFilter("Inventory Posting Group", FGPostingGroups);

//         if ItemCache.FindSet() then
//             repeat
//                 FGItemCache.Add(ItemCache."No.", true);

//                 ItemBaseMTCache.Add(
//                     ItemCache."No.",
//                     UpperCase(ItemCache."Base Unit of Measure") = 'MT');

//                 ItemNetWeightCache.Add(
//                     ItemCache."No.",
//                     ItemCache."Net Weight");
//             until ItemCache.Next() = 0;
//     end;


//     // =========================================================
//     // BUILD ALL ITEM LEDGER AGGREGATES IN ONE PASS
//     // =========================================================

//     local procedure BuildItemLedgerAggregates()
//     var
//         ILE: Record "Item Ledger Entry";
//         ItemNo: Code[20];
//         MT: Decimal;
//         Qty: Decimal;
//     begin
//         Clear(StockOpeningQtyByItem);
//         Clear(StockOpeningMTByItem);
//         Clear(PurchaseQtyByItem);
//         Clear(PurchaseMTByItem);
//         Clear(ProductionQtyByItem);
//         Clear(ProductionMTByItem);
//         Clear(SalesQtyByItem);
//         Clear(SalesMTByItem);
//         Clear(ConsumptionQtyByItem);
//         Clear(ConsumptionMTByItem);
//         Clear(TransferInQtyByItem);
//         Clear(TransferInMTByItem);
//         Clear(TransferOutQtyByItem);
//         Clear(TransferOutMTByItem);
//         Clear(PositiveAdjByItem);
//         Clear(NegativeAdjByItem);
//         Clear(StockClosingQtyByItem);
//         Clear(StockClosingMTByItem);

//         ILE.Reset();
//         ILE.SetFilter("Posting Date", '..%1', ReportDate);

//         if ILE.FindSet() then
//             repeat
//                 ItemNo := ILE."Item No.";

//                 if FGItemCache.ContainsKey(ItemNo) then begin
//                     Qty := ILE.Quantity;
//                     MT := GetCachedEntryMT(ItemNo, Qty);

//                     // Closing stock includes every entry through ReportDate.
//                     AddToDecimalDictionary(
//                         StockClosingQtyByItem,
//                         ItemNo,
//                         Qty);

//                     AddToDecimalDictionary(
//                         StockClosingMTByItem,
//                         ItemNo,
//                         MT);

//                     // Opening stock includes entries before ReportDate.
//                     if ILE."Posting Date" < ReportDate then begin
//                         AddToDecimalDictionary(
//                             StockOpeningQtyByItem,
//                             ItemNo,
//                             Qty);

//                         AddToDecimalDictionary(
//                             StockOpeningMTByItem,
//                             ItemNo,
//                             MT);
//                     end;

//                     // Today's movements.
//                     if ILE."Posting Date" = ReportDate then begin
//                         case ILE."Entry Type" of
//                             ILE."Entry Type"::Purchase:
//                                 begin
//                                     AddToDecimalDictionary(
//                                         PurchaseQtyByItem,
//                                         ItemNo,
//                                         Qty);
//                                     AddToDecimalDictionary(
//                                         PurchaseMTByItem,
//                                         ItemNo,
//                                         Abs(MT));
//                                 end;

//                             ILE."Entry Type"::Sale:
//                                 begin
//                                     AddToDecimalDictionary(
//                                         SalesQtyByItem,
//                                         ItemNo,
//                                         Abs(Qty));
//                                     AddToDecimalDictionary(
//                                         SalesMTByItem,
//                                         ItemNo,
//                                         Abs(MT));
//                                 end;

//                             ILE."Entry Type"::Output:
//                                 begin
//                                     AddToDecimalDictionary(
//                                         ProductionQtyByItem,
//                                         ItemNo,
//                                         Qty);
//                                     AddToDecimalDictionary(
//                                         ProductionMTByItem,
//                                         ItemNo,
//                                         Abs(MT));
//                                 end;

//                             ILE."Entry Type"::Consumption:
//                                 begin
//                                     AddToDecimalDictionary(
//                                         ConsumptionQtyByItem,
//                                         ItemNo,
//                                         Abs(Qty));
//                                     AddToDecimalDictionary(
//                                         ConsumptionMTByItem,
//                                         ItemNo,
//                                         Abs(MT));
//                                 end;

//                             ILE."Entry Type"::Transfer:
//                                 begin
//                                     if Qty > 0 then begin
//                                         AddToDecimalDictionary(
//                                             TransferInQtyByItem,
//                                             ItemNo,
//                                             Qty);
//                                         AddToDecimalDictionary(
//                                             TransferInMTByItem,
//                                             ItemNo,
//                                             Abs(MT));
//                                     end else begin
//                                         AddToDecimalDictionary(
//                                             TransferOutQtyByItem,
//                                             ItemNo,
//                                             Abs(Qty));
//                                         AddToDecimalDictionary(
//                                             TransferOutMTByItem,
//                                             ItemNo,
//                                             Abs(MT));
//                                     end;
//                                 end;

//                             ILE."Entry Type"::"Positive Adjmt.":
//                                 AddToDecimalDictionary(
//                                     PositiveAdjByItem,
//                                     ItemNo,
//                                     Abs(Qty));

//                             ILE."Entry Type"::"Negative Adjmt.":
//                                 AddToDecimalDictionary(
//                                     NegativeAdjByItem,
//                                     ItemNo,
//                                     Abs(Qty));
//                         end;
//                     end;
//                 end;
//             until ILE.Next() = 0;
//     end;


//     // =========================================================
//     // BUILD SALES VALUE AGGREGATES IN ONE PASS
//     // =========================================================

//     local procedure BuildSalesValueAggregates()
//     var
//         VE: Record "Value Entry";
//         ItemNo: Code[20];
//         Amount: Decimal;
//     begin
//         Clear(SalesAmountByItem);

//         VE.Reset();
//         VE.SetRange("Posting Date", ReportDate, ReportDate);
//         VE.SetRange(
//             "Item Ledger Entry Type",
//             VE."Item Ledger Entry Type"::Sale);

//         if VE.FindSet() then
//             repeat
//                 ItemNo := VE."Item No.";

//                 if FGItemCache.ContainsKey(ItemNo) then begin
//                     Amount := Abs(VE."Sales Amount (Actual)");

//                     AddToDecimalDictionary(
//                         SalesAmountByItem,
//                         ItemNo,
//                         Amount);
//                 end;
//             until VE.Next() = 0;
//     end;


//     // =========================================================
//     // CACHED MT CALCULATION
//     // =========================================================

//     local procedure GetCachedEntryMT(
//         ItemNo: Code[20];
//         Quantity: Decimal): Decimal
//     var
//         IsBaseMT: Boolean;
//         NetWeight: Decimal;
//     begin
//         if ItemBaseMTCache.Get(ItemNo, IsBaseMT) then
//             if IsBaseMT then
//                 exit(Quantity);

//         if ItemNetWeightCache.Get(ItemNo, NetWeight) then
//             if NetWeight <> 0 then
//                 exit(
//                     Quantity *
//                     NetWeight /
//                     1000);

//         exit(0);
//     end;


//     // =========================================================
//     // DICTIONARY ADD
//     // =========================================================

//     local procedure AddToDecimalDictionary(
//         var Dict: Dictionary of [Code[20], Decimal];
//         ItemNo: Code[20];
//         Amount: Decimal)
//     var
//         ExistingAmount: Decimal;
//     begin
//         if Dict.Get(ItemNo, ExistingAmount) then
//             Dict.Set(ItemNo, ExistingAmount + Amount)
//         else
//             Dict.Add(ItemNo, Amount);
//     end;


//     // =========================================================
//     // DICTIONARY GET
//     // =========================================================

//     local procedure GetDictDecimal(
//         var Dict: Dictionary of [Code[20], Decimal];
//         ItemNo: Code[20]): Decimal
//     var
//         Result: Decimal;
//     begin
//         if Dict.Get(ItemNo, Result) then
//             exit(Result);

//         exit(0);
//     end;



//     // =========================================================
//     // SALES LINE MT
//     // =========================================================

//     local procedure GetSalesLineMT(
//         SalesLine: Record "Sales Invoice Line"): Decimal
//     begin
//         exit(
//             GetDocumentLineMT(
//                 SalesLine."No.",
//                 SalesLine."Unit of Measure Code",
//                 SalesLine.Quantity));
//     end;


//     // =========================================================
//     // PURCHASE LINE MT
//     // =========================================================

//     local procedure GetPurchaseLineMT(
//         PurchaseLine: Record "Purch. Inv. Line"): Decimal
//     begin
//         exit(
//             GetDocumentLineMT(
//                 PurchaseLine."No.",
//                 PurchaseLine."Unit of Measure Code",
//                 PurchaseLine.Quantity));
//     end;


//     // =========================================================
//     // DOCUMENT LINE MT
//     // =========================================================

//     local procedure GetDocumentLineMT(
//         ItemNo: Code[20];
//         UOMCode: Code[10];
//         Quantity: Decimal): Decimal
//     var
//         ItemRec: Record Item;
//         ItemUOM: Record "Item Unit of Measure";
//         QtyPerUOM: Decimal;
//         EffectiveUOM: Code[10];
//         IsBaseMT: Boolean;
//         NetWeight: Decimal;
//     begin
//         if not ItemRec.Get(ItemNo) then
//             exit(0);

//         EffectiveUOM := UOMCode;

//         if EffectiveUOM = '' then
//             EffectiveUOM := ItemRec."Base Unit of Measure";

//         if UpperCase(EffectiveUOM) = 'MT' then
//             exit(Quantity);

//         QtyPerUOM := 1;

//         if ItemUOM.Get(ItemNo, EffectiveUOM) then
//             if ItemUOM."Qty. per Unit of Measure" <> 0 then
//                 QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

//         if FGItemCache.Get(ItemNo, IsBaseMT) then begin
//             if IsBaseMT then
//                 exit(Quantity * QtyPerUOM);

//             if ItemNetWeightCache.Get(ItemNo, NetWeight) then
//                 if NetWeight <> 0 then
//                     exit(
//                         Quantity *
//                         QtyPerUOM *
//                         NetWeight /
//                         1000);

//             exit(0);
//         end;

//         if UpperCase(ItemRec."Base Unit of Measure") = 'MT' then
//             exit(Quantity * QtyPerUOM);

//         if ItemRec."Net Weight" <> 0 then
//             exit(
//                 Quantity *
//                 QtyPerUOM *
//                 ItemRec."Net Weight" /
//                 1000);

//         exit(0);
//     end;

//     // =========================================================
//     // LEAD
//     // =========================================================

//     local procedure GetLeadName(
//         SalespersonCode: Code[20]): Text[100]
//     begin
//         if SalespersonCode = '' then
//             exit('');

//         if Salesperson.Get(
//             SalespersonCode)
//         then
//             exit(
//                 Salesperson.Name);

//         exit(
//             SalespersonCode);
//     end;


//     // =========================================================
//     // INVENTORY POSTING GROUP
//     // =========================================================

//     local procedure GetInventoryPostingGroup(
//         ItemNo: Code[20]): Code[20]
//     var
//         ItemRec: Record Item;
//     begin
//         if ItemRec.Get(
//             ItemNo)
//         then
//             exit(
//                 ItemRec."Inventory Posting Group");

//         exit('');
//     end;


//     // =========================================================
//     // ITEM SIZE
//     // =========================================================

//     local procedure GetItemSize(
//         ItemNo: Code[20]): Text[100]
//     var
//         ItemRec: Record Item;
//     begin
//         if ItemRec.Get(
//             ItemNo)
//         then
//             exit(
//                 ItemRec."Description 2");

//         exit('');
//     end;


//     // =========================================================
//     // FREIGHT
//     // =========================================================

//     local procedure GetFreightRecoverable(
//         SalesLine: Record "Sales Invoice Line"): Decimal
//     begin
//         // -----------------------------------------------------
//         // Freight Recoverable is not a standard BC field.
//         //
//         // Currently returns zero.
//         //
//         // Once the exact custom field is identified,
//         // this function can be connected to it.
//         // -----------------------------------------------------

//         exit(0);
//     end;


//     // =========================================================
//     // CUSTOMER NAME
//     // =========================================================

//     local procedure GetCustomerName(
//         CustomerNo: Code[20]): Text[100]
//     begin
//         if CustomerNo = '' then
//             exit('');

//         if Customer.Get(
//             CustomerNo)
//         then
//             exit(
//                 Customer.Name);

//         exit('');
//     end;


//     // =========================================================
//     // CUSTOMER NUMBER FROM DOCUMENT
//     // =========================================================

//     local procedure GetCustomerNoByDocument(
//         DocumentNo: Code[20];
//         PostingDate: Date): Code[20]
//     var
//         CLE: Record "Cust. Ledger Entry";
//     begin
//         CLE.Reset();

//         CLE.SetRange(
//             "Posting Date",
//             PostingDate,
//             PostingDate);

//         CLE.SetRange(
//             "Document No.",
//             DocumentNo);

//         CLE.SetRange(
//             "Document Type",
//             CLE."Document Type"::Payment);

//         if CLE.FindFirst() then
//             exit(
//                 CLE."Customer No.");

//         exit('');
//     end;


//     // =========================================================
//     // CUSTOMER NAME FROM DOCUMENT
//     // =========================================================

//     local procedure GetCustomerNameByDocument(
//         DocumentNo: Code[20];
//         PostingDate: Date): Text[100]
//     var
//         CustomerNo: Code[20];
//     begin
//         CustomerNo :=
//             GetCustomerNoByDocument(
//                 DocumentNo,
//                 PostingDate);

//         if CustomerNo <> '' then
//             exit(
//                 GetCustomerName(
//                     CustomerNo));

//         exit('');
//     end;


//     // =========================================================
//     // VENDOR NAME
//     // =========================================================

//     local procedure GetVendorName(
//         VendorNo: Code[20]): Text[100]
//     begin
//         if VendorNo = '' then
//             exit('');

//         if Vendor.Get(
//             VendorNo)
//         then
//             exit(
//                 Vendor.Name);

//         exit('');
//     end;


//     // =========================================================
//     // BANK NAME
//     // =========================================================

//     local procedure GetBankName(
//         BankAccountNo: Code[20]): Text[100]
//     begin
//         if BankAccount.Get(
//             BankAccountNo)
//         then
//             exit(
//                 BankAccount.Name);

//         exit('');
//     end;


//     // =========================================================
//     // G/L ACCOUNT NAME
//     // =========================================================

//     local procedure GetGLAccountName(
//         GLAccountNo: Code[20]): Text[100]
//     begin
//         if GLAccountNo = '' then
//             exit('');

//         if GLAccount.Get(
//             GLAccountNo)
//         then
//             exit(
//                 GLAccount.Name);

//         exit('');
//     end;


//     // =========================================================
//     // CLEAR STOCK VARIABLES
//     // =========================================================

//     local procedure ClearStockVariables()
//     begin
//         OpeningQty := 0;
//         OpeningMT := 0;

//         PurchaseQty := 0;
//         PurchaseMT := 0;

//         ProductionQty := 0;
//         ProductionMT := 0;

//         SalesStockQty := 0;
//         SalesStockMT := 0;

//         ConsumptionQty := 0;
//         ConsumptionMT := 0;

//         TransferInQty := 0;
//         TransferInMT := 0;

//         TransferOutQty := 0;
//         TransferOutMT := 0;

//         PositiveAdjustmentQty := 0;
//         NegativeAdjustmentQty := 0;

//         ClosingQty := 0;
//         ClosingMT := 0;
//     end;


//     // =========================================================
//     // EXCEL TITLE
//     // =========================================================

//     local procedure AddTitle(
//         Value: Text)
//     begin
//         ExcelBuffer.NewRow();

//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             true,
//             false,
//             false,
//             '@',
//             ExcelBuffer."Cell Type"::Text);
//     end;


//     // =========================================================
//     // EXCEL HEADER
//     // =========================================================

//     local procedure AddHeader(
//         Value: Text)
//     begin
//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             true,
//             false,
//             false,
//             '@',
//             ExcelBuffer."Cell Type"::Text);
//     end;


//     // =========================================================
//     // EXCEL TEXT
//     // =========================================================

//     local procedure AddText(
//         Value: Text)
//     begin
//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             false,
//             false,
//             false,
//             '@',
//             ExcelBuffer."Cell Type"::Text);
//     end;


//     // =========================================================
//     // EXCEL DATE
//     // =========================================================

//     local procedure AddDate(
//         Value: Date)
//     begin
//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             false,
//             false,
//             false,
//             'dd-mm-yyyy',
//             ExcelBuffer."Cell Type"::Date);
//     end;


//     // =========================================================
//     // EXCEL DECIMAL
//     // =========================================================

//     local procedure AddDecimal(
//         Value: Decimal)
//     begin
//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             false,
//             false,
//             false,
//             '#,##0.000',
//             ExcelBuffer."Cell Type"::Number);
//     end;


//     // =========================================================
//     // EXCEL INTEGER
//     // =========================================================

//     local procedure AddInteger(
//         Value: Integer)
//     begin
//         ExcelBuffer.AddColumn(
//             Value,
//             false,
//             '',
//             false,
//             false,
//             false,
//             '0',
//             ExcelBuffer."Cell Type"::Number);
//     end;
// }



