// Report 50702 "Aged Accounts Rec. Excel"
// {
//     //ApplicationArea = Basic, Suite;
//     ApplicationArea = All;
//     Caption = 'Aged Accounts Receivable Excel';
//     Permissions = tabledata Currency = R,
//         tabledata "Cust. Ledger Entry" = R,
//         tabledata Customer = R,
//         tabledata "Detailed Cust. Ledg. Entry" = R,
//         tabledata "Excel Buffer" = RD,
//         tabledata "General Ledger Setup" = R,
//         tabledata "Salesperson/Purchaser" = R;
//     ProcessingOnly = true;
//     UsageCategory = ReportsAndAnalysis;

//     dataset
//     {
//         dataitem(Customer; Customer)
//         {
//             RequestFilterFields = "No.";

//             trigger OnAfterGetRecord()
//             begin
//                 ProcessCustomer();
//             end;

//             trigger OnPreDataItem()
//             begin
//                 GLSetup.Get();
//                 CalcDates();
//                 CreateHeadings();
//                 ExcelBuffer.DeleteAll();
//                 CreateExcelHeader();
//             end;
//         }
//     }
//     requestpage
//     {
//         SaveValues = true;

//         layout
//         {
//             area(content)
//             {
//                 group(Options)
//                 {
//                     Caption = 'Options';

//                     field(AgedAsOf; EndingDate)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Aged As Of';
//                         ToolTip = 'Specifies the date that you want the aging calculated for.';
//                     }
//                     field(Agingby; AgingBy)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Aging by';
//                         OptionCaption = 'Due Date,Posting Date,Document Date';
//                         ToolTip = 'Specifies if the aging will be calculated from the due date, posting date, or document date.';
//                     }
//                     field(PeriodLength; PeriodLength)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Period Length';
//                         ToolTip = 'Specifies the period used for each aging bucket. Examples: 15D, 1M, 1Q, 1Y.';
//                     }
//                     field(AmountsinLCY; PrintAmountInLCY)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Print Amounts in LCY';
//                         ToolTip = 'Specifies if amounts are shown in local currency.';
//                     }
//                     field(PrintDetails; PrintDetails)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Print Details';
//                         ToolTip = 'Specifies if detailed customer ledger entries are included in the calculation.';
//                     }
//                     field(HeadingType; HeadingType)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Heading Type';
//                         OptionCaption = 'Date Interval,Number of Days';
//                         ToolTip = 'Specifies whether the aging columns show date intervals or number of days.';
//                     }
//                     field(SkipZeroBalanceCustomers; SkipZeroBalanceCustomers)
//                     {
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Skip Customers with Zero Balance';
//                         ToolTip = 'Specifies if customers with a zero balance are skipped.';
//                     }
//                 }
//             }
//         }
//         trigger OnOpenPage()
//         begin
//             if EndingDate = 0D then EndingDate := WorkDate();
//             if Format(PeriodLength) = '' then Evaluate(PeriodLength, '<1M>');
//         end;
//     }
//     trigger OnPreReport()
//     var
//         FormatDocument: Codeunit "Format Document";
//     begin
//         StartDateTime := CurrentDateTime();
//         CustFilter := FormatDocument.GetRecordFiltersWithCaptions(Customer);
//         GLSetup.Get();
//         CalcDates();
//         CreateHeadings();
//         CompanyDisplayName := COMPANYPROPERTY.DisplayName();
//     end;

//     trigger OnPostReport()
//     begin
//         AddGrandTotalRow();
//         CreateExcelFile();
//         FinishDateTime := CurrentDateTime();
//         LogReportTelemetry(StartDateTime, FinishDateTime, NumberOfLines);
//     end;

//     var
//         ExcelBuffer: Record "Excel Buffer";
//         GLSetup: Record "General Ledger Setup";
//         CustLedgEntryEndingDate: Record "Cust. Ledger Entry";
//         DetailedCustomerLedgerEntry: Record "Detailed Cust. Ledg. Entry";
//         SalespersonPurchaser: Record "Salesperson/Purchaser";
//         TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
//         TempCurrency: Record Currency temporary;
//         TotalCustLedgEntry: array[16] of Record "Cust. Ledger Entry";
//         GrandTotalCustLedgEntry: array[16] of Record "Cust. Ledger Entry";
//         AgedCustLedgEntry: array[17] of Record "Cust. Ledger Entry";
//         PeriodStartDate: array[16] of Date;
//         PeriodEndDate: array[16] of Date;
//         HeaderText: array[16] of Text[100];
//         PeriodLength: DateFormula;
//         EndingDate: Date;
//         AgingBy: Option "Due Date","Posting Date","Document Date";
//         HeadingType: Option "Date Interval","Number of Days";
//         PrintAmountInLCY: Boolean;
//         PrintDetails: Boolean;
//         SkipZeroBalanceCustomers: Boolean;
//         NewPagePercustomer: Boolean;
//         CurrencyCode: Code[10];
//         CompanyDisplayName: Text;
//         CustFilter: Text;
//         RowNo: Integer;
//         NumberOfLines: Integer;
//         NumberOfCurrencies: Integer;
//         PageGroupNo: Integer;
//         NextPageGroupNo: Integer;
//         CustFilterCheck: Boolean;
//         StartDateTime: DateTime;
//         FinishDateTime: DateTime;
//         Text000: Label 'Not Due';
//         Text002: Label 'days';
//         Text004: Label 'Aged by %1';
//         Text005: Label 'Total for %1';
//         Text006: Label 'Aged as of %1';
//         Text007: Label 'Aged by %1';
//         Text009: Label 'Due Date,Posting Date,Document Date';
//         Text010: Label 'The Date Formula %1 cannot be used. Try to restate it. E.g. 1M+CM instead of CM+1M.';
//         Text032Txt: Label '-%1', Comment = 'Negating the period length: %1 is the period length';
//         AfterTok: Label 'After';
//         BeforeTok: Label 'Before';
//         EnterDateFormulaErr: Label 'Enter a date formula in the Period Length field.';
//         TelemetryCategoryTxt: Label 'Report', Locked = true;
//         AgedARReportGeneratedTxt: Label 'Aged AR Excel Report generated.', Locked = true;

//     local procedure ProcessCustomer()
//     begin
//         if SkipZeroBalanceCustomers then begin
//             Customer.SetRange("Date Filter", 0D, EndingDate);
//             Customer.CalcFields("Net Change");
//             if Customer."Net Change" = 0 then exit;
//             Customer.SetRange("Date Filter");
//         end;
//         Clear(SalespersonPurchaser);
//         if Customer."Salesperson Code" <> '' then SalespersonPurchaser.Get(Customer."Salesperson Code");
//         TempCustLedgEntry.Reset();
//         TempCustLedgEntry.DeleteAll();
//         TempCurrency.Reset();
//         TempCurrency.DeleteAll();
//         Clear(TotalCustLedgEntry);
//         Clear(AgedCustLedgEntry);
//         CollectCustomerLedgerEntries();
//         if not TempCustLedgEntry.FindSet(false) then exit;
//         if PrintAmountInLCY then begin
//             CurrencyCode := GLSetup."LCY Code";
//             ProcessCustomerCurrency();
//             if CustomerBalanceExists() then WriteCustomerRow();
//         end
//         else begin
//             if not TempCurrency.FindSet(false) then exit;
//             repeat
//                 Clear(TotalCustLedgEntry);
//                 Clear(AgedCustLedgEntry);
//                 if TempCurrency.Code <> '' then
//                     CurrencyCode := TempCurrency.Code
//                 else
//                     CurrencyCode := GLSetup."LCY Code";
//                 ProcessCustomerCurrency();
//                 if CustomerBalanceExists() then WriteCustomerRow();
//             until TempCurrency.Next() = 0;
//         end;
//     end;

//     local procedure CollectCustomerLedgerEntries()
//     var
//         CustLedgEntry: Record "Cust. Ledger Entry";
//     begin
//         CollectPostedCustomerLedgerEntries(CustLedgEntry);
//         CollectFutureCustomerLedgerEntries();
//         CollectOpenCustomerLedgerEntries(CustLedgEntry);
//     end;

//     local procedure CollectPostedCustomerLedgerEntries(var CustLedgEntry: Record "Cust. Ledger Entry")
//     begin
//         CustLedgEntry.Reset();
//         CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//         CustLedgEntry.SetRange("Customer No.", Customer."No.");
//         CustLedgEntry.SetRange("Posting Date", 0D, EndingDate);
//         CopyDimFiltersFromCustomer(CustLedgEntry);
//         Customer.CopyFilter("Currency Filter", CustLedgEntry."Currency Code");
//         if CustLedgEntry.FindSet(false) then
//             repeat
//                 InsertTemp(CustLedgEntry);
//             until CustLedgEntry.Next() = 0;
//     end;

//     local procedure CollectFutureCustomerLedgerEntries()
//     var
//         FutureCustLedgEntry: Record "Cust. Ledger Entry";
//         ClosedCustLedgEntry: Record "Cust. Ledger Entry";
//     begin
//         FutureCustLedgEntry.Reset();
//         FutureCustLedgEntry.SetRange("Customer No.", Customer."No.");
//         FutureCustLedgEntry.SetRange("Posting Date", EndingDate + 1, DMY2Date(31, 12, 9999));
//         CopyDimFiltersFromCustomer(FutureCustLedgEntry);
//         Customer.CopyFilter("Currency Filter", FutureCustLedgEntry."Currency Code");
//         if FutureCustLedgEntry.FindSet(false) then
//             repeat
//                 ClosedCustLedgEntry.Reset();
//                 ClosedCustLedgEntry.SetCurrentKey("Closed by Entry No.");
//                 if FutureCustLedgEntry."Closed by Entry No." <> 0 then
//                     ClosedCustLedgEntry.SetFilter("Closed by Entry No.", '%1|%2', FutureCustLedgEntry."Entry No.", FutureCustLedgEntry."Closed by Entry No.")
//                 else
//                     ClosedCustLedgEntry.SetRange("Closed by Entry No.", FutureCustLedgEntry."Entry No.");
//                 ClosedCustLedgEntry.SetRange("Posting Date", 0D, EndingDate);
//                 CopyDimFiltersFromCustomer(ClosedCustLedgEntry);
//                 Customer.CopyFilter("Currency Filter", ClosedCustLedgEntry."Currency Code");
//                 if ClosedCustLedgEntry.FindSet(false) then
//                     repeat
//                         InsertTemp(ClosedCustLedgEntry);
//                     until ClosedCustLedgEntry.Next() = 0;
//                 ClosedCustLedgEntry.Reset();
//                 ClosedCustLedgEntry.SetRange("Entry No.", FutureCustLedgEntry."Closed by Entry No.");
//                 ClosedCustLedgEntry.SetRange("Posting Date", 0D, EndingDate);
//                 CopyDimFiltersFromCustomer(ClosedCustLedgEntry);
//                 Customer.CopyFilter("Currency Filter", ClosedCustLedgEntry."Currency Code");
//                 if ClosedCustLedgEntry.FindSet(false) then
//                     repeat
//                         InsertTemp(ClosedCustLedgEntry);
//                     until ClosedCustLedgEntry.Next() = 0;
//             until FutureCustLedgEntry.Next() = 0;
//     end;

//     local procedure CollectOpenCustomerLedgerEntries(var CustLedgEntry: Record "Cust. Ledger Entry")
//     begin
//         CustLedgEntry.Reset();
//         CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
//         CustLedgEntry.SetRange("Customer No.", Customer."No.");
//         if AgingBy = AgingBy::"Posting Date" then begin
//             CustLedgEntry.SetRange("Posting Date", 0D, EndingDate);
//             CustLedgEntry.SetRange("Date Filter", 0D, EndingDate);
//             CustLedgEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
//             CustLedgEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
//         end;
//         CopyDimFiltersFromCustomer(CustLedgEntry);
//         Customer.CopyFilter("Currency Filter", CustLedgEntry."Currency Code");
//         if CustLedgEntry.FindSet(false) then
//             repeat
//                 InsertTemp(CustLedgEntry);
//             until CustLedgEntry.Next() = 0;
//     end;

//     local procedure ProcessCustomerCurrency()
//     var
//         PeriodIndex: Integer;
//     begin
//         TempCustLedgEntry.Reset();
//         if not PrintAmountInLCY then begin
//             if (CurrencyCode = '') or (CurrencyCode = GLSetup."LCY Code") then
//                 TempCustLedgEntry.SetFilter("Currency Code", '%1|%2', GLSetup."LCY Code", '')
//             else
//                 TempCustLedgEntry.SetRange("Currency Code", CurrencyCode);
//         end;
//         if not TempCustLedgEntry.FindSet(false) then exit;
//         repeat
//             CustLedgEntryEndingDate := TempCustLedgEntry;
//             CalculateDetailedRemainingAmount();
//             if CustLedgEntryEndingDate."Remaining Amount" <> 0 then begin
//                 PeriodIndex := GetAgingPeriodIndex();
//                 if PeriodIndex > 0 then begin
//                     Clear(AgedCustLedgEntry);
//                     AgedCustLedgEntry[PeriodIndex]."Remaining Amount" := CustLedgEntryEndingDate."Remaining Amount";
//                     AgedCustLedgEntry[PeriodIndex]."Remaining Amt. (LCY)" := CustLedgEntryEndingDate."Remaining Amt. (LCY)";
//                     TotalCustLedgEntry[PeriodIndex]."Remaining Amount" += CustLedgEntryEndingDate."Remaining Amount";
//                     TotalCustLedgEntry[PeriodIndex]."Remaining Amt. (LCY)" += CustLedgEntryEndingDate."Remaining Amt. (LCY)";
//                     GrandTotalCustLedgEntry[PeriodIndex]."Remaining Amount" += CustLedgEntryEndingDate."Remaining Amount";
//                     GrandTotalCustLedgEntry[PeriodIndex]."Remaining Amt. (LCY)" += CustLedgEntryEndingDate."Remaining Amt. (LCY)";
//                     TotalCustLedgEntry[1].Amount += CustLedgEntryEndingDate."Remaining Amount";
//                     TotalCustLedgEntry[1]."Amount (LCY)" += CustLedgEntryEndingDate."Remaining Amt. (LCY)";
//                     GrandTotalCustLedgEntry[1].Amount += CustLedgEntryEndingDate."Remaining Amount";
//                     GrandTotalCustLedgEntry[1]."Amount (LCY)" += CustLedgEntryEndingDate."Remaining Amt. (LCY)";
//                     NumberOfLines += 1;
//                 end;
//             end;
//         until TempCustLedgEntry.Next() = 0;
//     end;

//     local procedure CalculateDetailedRemainingAmount()
//     begin
//         DetailedCustomerLedgerEntry.Reset();
//         DetailedCustomerLedgerEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntryEndingDate."Entry No.");
//         OnTempCustLedgEntryGetRecordOnAfterSetDetailedEntryFilters(DetailedCustomerLedgerEntry);
//         if DetailedCustomerLedgerEntry.FindSet(false) then
//             repeat
//                 if (DetailedCustomerLedgerEntry."Entry Type" = DetailedCustomerLedgerEntry."Entry Type"::"Initial Entry") and (CustLedgEntryEndingDate."Posting Date" > EndingDate) and (AgingBy <> AgingBy::"Posting Date") then
//                     if CustLedgEntryEndingDate."Document Date" <= EndingDate then
//                         DetailedCustomerLedgerEntry."Posting Date" := CustLedgEntryEndingDate."Document Date"
//                     else if (CustLedgEntryEndingDate."Due Date" <= EndingDate) and (AgingBy = AgingBy::"Due Date") then DetailedCustomerLedgerEntry."Posting Date" := CustLedgEntryEndingDate."Due Date";
//                 if (DetailedCustomerLedgerEntry."Posting Date" <= EndingDate) or (TempCustLedgEntry.Open and (AgingBy = AgingBy::"Due Date") and (CustLedgEntryEndingDate."Due Date" > EndingDate) and (CustLedgEntryEndingDate."Posting Date" <= EndingDate)) then begin
//                     OnCustomerOnAfterGetRecordOnBeforeSetCustLedgEntryEndingDateAmount(CustLedgEntryEndingDate, DetailedCustomerLedgerEntry);
//                     if DetailedCustomerLedgerEntry."Entry Type" in [DetailedCustomerLedgerEntry."Entry Type"::"Initial Entry", DetailedCustomerLedgerEntry."Entry Type"::"Unrealized Loss", DetailedCustomerLedgerEntry."Entry Type"::"Unrealized Gain", DetailedCustomerLedgerEntry."Entry Type"::"Realized Loss", DetailedCustomerLedgerEntry."Entry Type"::"Realized Gain", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount (VAT Excl.)", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount (VAT Adjustment)", DetailedCustomerLedgerEntry."Entry Type"::"Payment Tolerance", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount Tolerance", DetailedCustomerLedgerEntry."Entry Type"::"Payment Tolerance (VAT Excl.)", DetailedCustomerLedgerEntry."Entry Type"::"Payment Tolerance (VAT Adjustment)", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount Tolerance (VAT Excl.)", DetailedCustomerLedgerEntry."Entry Type"::"Payment Discount Tolerance (VAT Adjustment)"] then begin
//                         CustLedgEntryEndingDate.Amount := CustLedgEntryEndingDate.Amount + DetailedCustomerLedgerEntry.Amount;
//                         CustLedgEntryEndingDate."Amount (LCY)" := CustLedgEntryEndingDate."Amount (LCY)" + DetailedCustomerLedgerEntry."Amount (LCY)";
//                     end;
//                     if DetailedCustomerLedgerEntry."Posting Date" <= EndingDate then begin
//                         CustLedgEntryEndingDate."Remaining Amount" := CustLedgEntryEndingDate."Remaining Amount" + DetailedCustomerLedgerEntry.Amount;
//                         CustLedgEntryEndingDate."Remaining Amt. (LCY)" := CustLedgEntryEndingDate."Remaining Amt. (LCY)" + DetailedCustomerLedgerEntry."Amount (LCY)";
//                     end;
//                 end;
//             until DetailedCustomerLedgerEntry.Next() = 0;
//     end;

//     local procedure GetAgingPeriodIndex(): Integer
//     var
//         PeriodIndex: Integer;
//     begin
//         case AgingBy of
//             AgingBy::"Due Date":
//                 PeriodIndex := GetPeriodIndex(CustLedgEntryEndingDate."Due Date");
//             AgingBy::"Posting Date":
//                 PeriodIndex := GetPeriodIndex(CustLedgEntryEndingDate."Posting Date");
//             AgingBy::"Document Date":
//                 begin
//                     if CustLedgEntryEndingDate."Document Date" > EndingDate then begin
//                         CustLedgEntryEndingDate."Remaining Amount" := 0;
//                         CustLedgEntryEndingDate."Remaining Amt. (LCY)" := 0;
//                         CustLedgEntryEndingDate."Document Date" := CustLedgEntryEndingDate."Posting Date";
//                     end;
//                     PeriodIndex := GetPeriodIndex(CustLedgEntryEndingDate."Document Date");
//                 end;
//         end;
//         exit(PeriodIndex);
//     end;

//     local procedure CustomerBalanceExists(): Boolean
//     begin
//         exit(TotalCustLedgEntry[1]."Amount (LCY)" <> 0);
//     end;

//     local procedure WriteCustomerRow()
//     var
//         Balance: Decimal;
//         i: Integer;
//     begin
//         if PrintAmountInLCY then
//             Balance := TotalCustLedgEntry[1]."Amount (LCY)"
//         else
//             Balance := TotalCustLedgEntry[1].Amount;
//         if Balance = 0 then exit;
//         RowNo += 1;
//         ExcelBuffer.NewRow();
//         ExcelBuffer.AddColumn(Customer."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn(Customer.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn(Customer."Salesperson Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn(SalespersonPurchaser.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn(Balance, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
//         for i := 1 to ArrayLen(PeriodEndDate) do if PrintAmountInLCY then
//                 ExcelBuffer.AddColumn(TotalCustLedgEntry[i]."Remaining Amt. (LCY)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
//             else
//                 ExcelBuffer.AddColumn(TotalCustLedgEntry[i]."Remaining Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
//     end;

//     local procedure AddGrandTotalRow()
//     var
//         i: Integer;
//         Balance: Decimal;
//     begin
//         ExcelBuffer.NewRow();
//         ExcelBuffer.AddColumn('Grand Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         if PrintAmountInLCY then
//             Balance := GrandTotalCustLedgEntry[1]."Amount (LCY)"
//         else
//             Balance := GrandTotalCustLedgEntry[1].Amount;
//         ExcelBuffer.AddColumn(Balance, false, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
//         for i := 1 to ArrayLen(PeriodEndDate) do if PrintAmountInLCY then
//                 ExcelBuffer.AddColumn(GrandTotalCustLedgEntry[i]."Remaining Amt. (LCY)", false, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
//             else
//                 ExcelBuffer.AddColumn(GrandTotalCustLedgEntry[i]."Remaining Amount", false, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
//     end;

//     local procedure CreateExcelHeader()
//     var
//         i: Integer;
//     begin
//         ExcelBuffer.NewRow();
//         ExcelBuffer.AddColumn('No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('Salesperson Code', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('Salesperson Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         ExcelBuffer.AddColumn('Balance', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//         for i := 1 to ArrayLen(HeaderText) do if HeaderText[i] <> '' then ExcelBuffer.AddColumn(HeaderText[i], false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
//     end;

//     local procedure CalcDates()
//     var
//         PeriodLength2: DateFormula;
//         i: Integer;
//     begin
//         Clear(PeriodStartDate);
//         Clear(PeriodEndDate);
//         if not Evaluate(PeriodLength2, StrSubstNo(Text032Txt, PeriodLength)) then Error(EnterDateFormulaErr);
//         if AgingBy = AgingBy::"Due Date" then begin
//             PeriodEndDate[1] := DMY2Date(31, 12, 9999);
//             PeriodStartDate[1] := EndingDate + 1;
//         end
//         else begin
//             PeriodEndDate[1] := EndingDate;
//             PeriodStartDate[1] := CalcDate(PeriodLength2, EndingDate + 1);
//         end;
//         for i := 2 to ArrayLen(PeriodEndDate) do begin
//             PeriodEndDate[i] := PeriodStartDate[i - 1] - 1;
//             PeriodStartDate[i] := CalcDate(PeriodLength2, PeriodEndDate[i] + 1);
//         end;
//         PeriodStartDate[ArrayLen(PeriodStartDate)] := 0D;
//         for i := 1 to ArrayLen(PeriodEndDate) do if PeriodEndDate[i] < PeriodStartDate[i] then Error(Text010, PeriodLength);
//     end;

//     local procedure CreateHeadings()
//     var
//         i: Integer;
//     begin
//         Clear(HeaderText);
//         if AgingBy = AgingBy::"Due Date" then begin
//             HeaderText[1] := Text000;
//             i := 2;
//         end
//         else
//             i := 1;
//         while i < ArrayLen(PeriodEndDate) do begin
//             if HeadingType = HeadingType::"Date Interval" then
//                 HeaderText[i] := StrSubstNo('%1\..%2', PeriodStartDate[i], PeriodEndDate[i])
//             else
//                 HeaderText[i] := StrSubstNo('%1 - %2 %3', EndingDate - PeriodEndDate[i] + 1, EndingDate - PeriodStartDate[i] + 1, Text002);
//             i += 1;
//         end;
//         if HeadingType = HeadingType::"Date Interval" then
//             HeaderText[i] := StrSubstNo('%1 %2', BeforeTok, PeriodStartDate[i - 1])
//         else
//             HeaderText[i] := StrSubstNo('%1 %2 %3', AfterTok, EndingDate - PeriodStartDate[i - 1] + 1, Text002);
//     end;

//     local procedure GetPeriodIndex(Date: Date): Integer
//     var
//         i: Integer;
//     begin
//         for i := 1 to ArrayLen(PeriodEndDate) do if Date in [PeriodStartDate[i] .. PeriodEndDate[i]] then exit(i);
//         exit(0);
//     end;

//     local procedure InsertTemp(var CustLedgEntry: Record "Cust. Ledger Entry")
//     var
//         Currency: Record Currency;
//     begin
//         if TempCustLedgEntry.Get(CustLedgEntry."Entry No.") then exit;
//         TempCustLedgEntry := CustLedgEntry;
//         TempCustLedgEntry.Insert();
//         if PrintAmountInLCY then begin
//             Clear(TempCurrency);
//             TempCurrency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
//             if TempCurrency.Insert() then;
//             exit;
//         end;
//         if TempCurrency.Get(TempCustLedgEntry."Currency Code") then exit;
//         if TempCurrency.Get('') and (TempCustLedgEntry."Currency Code" = GLSetup."LCY Code") then exit;
//         if TempCurrency.Get(GLSetup."LCY Code") and (TempCustLedgEntry."Currency Code" = '') then exit;
//         if TempCustLedgEntry."Currency Code" <> '' then
//             Currency.Get(TempCustLedgEntry."Currency Code")
//         else begin
//             Clear(Currency);
//             Currency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
//         end;
//         TempCurrency := Currency;
//         TempCurrency.Insert();
//     end;

//     local procedure CopyDimFiltersFromCustomer(var CustLedgerEntry: Record "Cust. Ledger Entry")
//     begin
//         if Customer.GetFilter("Global Dimension 1 Filter") <> '' then CustLedgerEntry.SetFilter("Global Dimension 1 Code", Customer.GetFilter("Global Dimension 1 Filter"));
//         if Customer.GetFilter("Global Dimension 2 Filter") <> '' then CustLedgerEntry.SetFilter("Global Dimension 2 Code", Customer.GetFilter("Global Dimension 2 Filter"));
//     end;

//     local procedure CreateExcelFile()
//     var
//         FileName: Text;
//     begin
//         FileName := StrSubstNo('Aged Accounts Receivable %1.xlsx', Format(EndingDate, 0, '<Year4><Month,2><Day,2>'));
//         ExcelBuffer.CreateNewBook('Aged Accounts Receivable');
//         ExcelBuffer.WriteSheet('Aged Accounts Receivable', CompanyDisplayName, UserId());
//         ExcelBuffer.CloseBook();
//         ExcelBuffer.SetFriendlyFilename(FileName);
//         ExcelBuffer.OpenExcel();
//     end;

//     local procedure LogReportTelemetry(StartDateTime: DateTime; FinishDateTime: DateTime; NumberOfLines: Integer)
//     var
//         ReportDuration: BigInteger;
//         Dimensions: Dictionary of [Text, Text];
//     begin
//         ReportDuration := FinishDateTime - StartDateTime;
//         Dimensions.Add('Category', TelemetryCategoryTxt);
//         Dimensions.Add('ReportStartTime', Format(StartDateTime, 0, 9));
//         Dimensions.Add('ReportFinishTime', Format(FinishDateTime, 0, 9));
//         Dimensions.Add('ReportDuration', Format(ReportDuration));
//         Dimensions.Add('NumberOfLines', Format(NumberOfLines));
//         Session.LogMessage('0000FJM', AgedARReportGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
//     end;

//     procedure InitializeRequest(NewEndingDate: Date; NewAgingBy: Option; NewPeriodLength: DateFormula; NewPrintAmountInLCY: Boolean; NewPrintDetails: Boolean; NewHeadingType: Option; NewPagePercust: Boolean)
//     begin
//         EndingDate := NewEndingDate;
//         AgingBy := NewAgingBy;
//         PeriodLength := NewPeriodLength;
//         PrintAmountInLCY := NewPrintAmountInLCY;
//         PrintDetails := NewPrintDetails;
//         HeadingType := NewHeadingType;
//         NewPagePercustomer := NewPagePercust;
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnTempCustLedgEntryGetRecordOnAfterSetDetailedEntryFilters(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnCustomerOnAfterGetRecordOnBeforeSetCustLedgEntryEndingDateAmount(var CustLedgEntryEndingDate: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
//     begin
//     end;
// }
