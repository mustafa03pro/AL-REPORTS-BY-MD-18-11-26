report 50205 "Monthly Purchase Summary"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Monthly Purchase Summary';
    DefaultLayout = Excel;
    ExcelLayout = './ReportLayouts/MonthlyPurchases.xlsx';

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.", "Vendor Posting Group";

            column(ReportYear; TargetYear) { }
            column(ReportMonth; TargetMonth) { }
            column(VendorNo; "No.") { }
            column(VendorName; Name) { }
            column(VendorTotalPurchases; VendorMonthlyPurch) { }

            trigger OnAfterGetRecord()
            var
                VendLedgEntry: Record "Vendor Ledger Entry";
            begin
                VendorMonthlyPurch := 0;

                // 1. Sum Invoices for this vendor in the month
                VendLedgEntry.Reset();
                VendLedgEntry.SetRange("Vendor No.", "No.");
                VendLedgEntry.SetRange("Posting Date", StartDate, EndDate);
                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
                VendLedgEntry.CalcSums("Purchase (LCY)");
                VendorMonthlyPurch := VendLedgEntry."Purchase (LCY)";

                // 2. Subtract Credit Memos for returns
                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
                VendLedgEntry.CalcSums("Purchase (LCY)");
                VendorMonthlyPurch -= VendLedgEntry."Purchase (LCY)";

                // Skip vendors with no purchases in that period
                if VendorMonthlyPurch = 0 then
                    CurrReport.Skip();

                TotalMonthlyPurch += VendorMonthlyPurch;
            end;
        }

        // Summary totals dataitem
        dataitem(SummaryTotals; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(GrandTotalPurchases; TotalMonthlyPurch) { }
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
                    Caption = 'Period Selection';
                    field(MonthField; TargetMonth)
                    {
                        ApplicationArea = All;
                        Caption = 'Month (1 - 12)';
                        MinValue = 1;
                        MaxValue = 12;
                    }
                    field(YearField; TargetYear)
                    {
                        ApplicationArea = All;
                        Caption = 'Year';
                        MinValue = 2000;
                        MaxValue = 2099;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if TargetYear = 0 then
                TargetYear := Date2DMY(WorkDate(), 3);
            if TargetMonth = 0 then
                TargetMonth := Date2DMY(WorkDate(), 2);
        end;
    }

    trigger OnPreReport()
    begin
        if (TargetMonth < 1) or (TargetMonth > 12) or (TargetYear < 2000) then
            Error('Please enter a valid Month and Year.');

        // Compute start and end date of the selected month
        StartDate := DMY2Date(1, TargetMonth, TargetYear);
        EndDate := CalcDate('<1M-1D>', StartDate);
    end;

    var
        TargetMonth: Integer;
        TargetYear: Integer;
        StartDate: Date;
        EndDate: Date;
        VendorMonthlyPurch: Decimal;
        TotalMonthlyPurch: Decimal;
}