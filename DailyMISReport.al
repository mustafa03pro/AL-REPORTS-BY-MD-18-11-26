report 50212 "Daily MIS Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Daily MIS Report';
    DefaultLayout = RDLC;
    RDLCLayout = './DailyMISReport.rdl';

    dataset
    {
        // -------------------------------------------------------------
        // 1. Daily Financial Summaries (Sales, Purchases, Cash, Bank)
        // -------------------------------------------------------------
        dataitem(Parameters; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(ReportDate; AsOfDate) { }
            column(CompanyName; COMPANYPROPERTY.DisplayName()) { }
            column(TotalSalesAmount; TotalSales) { }
            column(TotalPurchaseAmount; TotalPurch) { }
            column(DayCashReceipts; DayCashIn) { }
            column(DayCashPayments; DayCashOut) { }
            column(CashClosingBalance; CashBal) { }
            column(DayBankReceipts; DayBankIn) { }
            column(DayBankPayments; DayBankOut) { }
            column(BankClosingBalance; BankBal) { }

            trigger OnAfterGetRecord()
            begin
                CalculateDailyFinancials();
            end;
        }

        // -------------------------------------------------------------
        // 2. Finished Goods Details (TMT FE-500, Binding Wire, Randoms)
        // -------------------------------------------------------------
        dataitem(FinishedGood; Item)
        {
            DataItemTableView = sorting("No.") where(
                "Inventory Posting Group" = filter('FG TMT BARS FE-500|FG - BINDING WIRE|TMT BARS RANDOMS|RANDOM')
            );
            RequestFilterFields = "No.", "Inventory Posting Group";

            column(Item_No; "No.") { }
            column(Item_Description; Description) { }
            column(Base_UOM; "Base Unit of Measure") { }
            column(Inventory_Posting_Group; "Inventory Posting Group") { }
            column(OpeningStock; OpeningQty) { }
            column(ProductionQty; ProductionQty) { }
            column(SalesQty; DaySalesQty) { }
            column(ClosingStock; ClosingQty) { }

            trigger OnAfterGetRecord()
            var
                ILE: Record "Item Ledger Entry";
            begin
                OpeningQty := 0;
                ProductionQty := 0;
                DaySalesQty := 0;
                ClosingQty := 0;

                // Opening Stock: Movements strictly before selected date
                ILE.Reset();
                ILE.SetRange("Item No.", "No.");
                ILE.SetFilter("Posting Date", '<%1', AsOfDate);
                ILE.CalcSums(Quantity);
                OpeningQty := ILE.Quantity;

                // Day's Production Output
                ILE.Reset();
                ILE.SetRange("Item No.", "No.");
                ILE.SetRange("Posting Date", AsOfDate);
                ILE.SetRange("Entry Type", ILE."Entry Type"::Output);
                ILE.CalcSums(Quantity);
                ProductionQty := ILE.Quantity;

                // Day's Net Sales
                ILE.Reset();
                ILE.SetRange("Item No.", "No.");
                ILE.SetRange("Posting Date", AsOfDate);
                ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                ILE.CalcSums(Quantity);
                DaySalesQty := -ILE.Quantity;

                // Closing Stock: Balance through selected date
                ILE.Reset();
                ILE.SetRange("Item No.", "No.");
                ILE.SetFilter("Posting Date", '..%1', AsOfDate);
                ILE.CalcSums(Quantity);
                ClosingQty := ILE.Quantity;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Filters & Options';
                    field(AsOfDateField; AsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'MIS Date';
                        ToolTip = 'Select the date for the daily MIS report.';
                    }
                    field(CashGLFilterField; CashGLFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Cash G/L Account(s)';
                        ToolTip = 'Enter cash account numbers (e.g., 10100..10120 or 10100|10110).';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccList: Page "G/L Account List";
                        begin
                            GLAccList.LookupMode(true);
                            if GLAccList.RunModal() = Action::LookupOK then begin
                                Text := GLAccList.GetSelectionFilter();
                                exit(true);
                            end;
                        end;
                    }
                    field(BankGLFilterField; BankGLFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Bank G/L Account(s)';
                        ToolTip = 'Enter bank account numbers (e.g., 10200..10290 or 10210|10220).';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccList: Page "G/L Account List";
                        begin
                            GLAccList.LookupMode(true);
                            if GLAccList.RunModal() = Action::LookupOK then begin
                                Text := GLAccList.GetSelectionFilter();
                                exit(true);
                            end;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if AsOfDate = 0D then
                AsOfDate := WorkDate();
        end;
    }

    var
        AsOfDate: Date;
        CashGLFilter: Code[250];
        BankGLFilter: Code[250];
        OpeningQty: Decimal;
        ProductionQty: Decimal;
        DaySalesQty: Decimal;
        ClosingQty: Decimal;
        TotalSales: Decimal;
        TotalPurch: Decimal;
        CashBal: Decimal;
        BankBal: Decimal;
        DayCashIn: Decimal;
        DayCashOut: Decimal;
        DayBankIn: Decimal;
        DayBankOut: Decimal;

    local procedure CalculateDailyFinancials()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        // --- 1. NET INVOICED SALES FOR THE DAY ---
        CustLedgEntry.Reset();
        CustLedgEntry.SetRange("Posting Date", AsOfDate);
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.CalcSums("Sales (LCY)");
        TotalSales := CustLedgEntry."Sales (LCY)";

        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Sales (LCY)");
        TotalSales -= CustLedgEntry."Sales (LCY)";

        // --- 2. NET INVOICED PURCHASES FOR THE DAY ---
        VendLedgEntry.Reset();
        VendLedgEntry.SetRange("Posting Date", AsOfDate);
        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
        VendLedgEntry.CalcSums("Purchase (LCY)");
        TotalPurch := VendLedgEntry."Purchase (LCY)";

        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
        VendLedgEntry.CalcSums("Purchase (LCY)");
        TotalPurch -= VendLedgEntry."Purchase (LCY)";

        // --- 3. CASH G/L MOVEMENTS & CLOSING BALANCE ---
        CashBal := 0;
        DayCashIn := 0;
        DayCashOut := 0;

        if CashGLFilter <> '' then begin
            // Closing Balance as of AsOfDate
            GLEntry.Reset();
            GLEntry.SetFilter("G/L Account No.", CashGLFilter);
            GLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
            GLEntry.CalcSums(Amount);
            CashBal := GLEntry.Amount;

            // Day's Inflow (Debits) and Outflow (Credits)
            GLEntry.SetRange("Posting Date", AsOfDate);
            GLEntry.CalcSums("Debit Amount", "Credit Amount");
            DayCashIn := GLEntry."Debit Amount";
            DayCashOut := GLEntry."Credit Amount";
        end;

        // --- 4. BANK G/L MOVEMENTS & CLOSING BALANCE ---
        BankBal := 0;
        DayBankIn := 0;
        DayBankOut := 0;

        if BankGLFilter <> '' then begin
            // Closing Balance as of AsOfDate
            GLEntry.Reset();
            GLEntry.SetFilter("G/L Account No.", BankGLFilter);
            GLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
            GLEntry.CalcSums(Amount);
            BankBal := GLEntry.Amount;

            // Day's Inflow (Debits) and Outflow (Credits)
            GLEntry.SetRange("Posting Date", AsOfDate);
            GLEntry.CalcSums("Debit Amount", "Credit Amount");
            DayBankIn := GLEntry."Debit Amount";
            DayBankOut := GLEntry."Credit Amount";
        end;
    end;
}