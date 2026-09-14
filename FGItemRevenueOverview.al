
report 50208 "FG Item Revenue Overview"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Item Inventory, Sales & Profit Report';

    DefaultLayout = RDLC;
    RDLCLayout = './ReportLayouts/FGItemRevenueOverview.rdlc';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Gen. Prod. Posting Group";

            column(No_Item; "No.")
            {
            }

            column(Description_Item; Description)
            {
            }

            column(BaseUnitOfMeasure; "Base Unit of Measure")
            {
            }

            column(GenProdPostingGroup; "Gen. Prod. Posting Group")
            {
            }

            column(StartDate_Report; StartDate)
            {
            }

            column(EndDate_Report; EndDate)
            {
            }

            // Current available inventory
            column(Inventory; Inventory)
            {
            }

            // Sales quantity during selected period
            column(SalesQty; TotalQty)
            {
            }

            // Sales amount during selected period
            column(SalesAmount; TotalAmount)
            {
            }

            // Profit during selected period
            column(TotalProfit; TotalProfit)
            {
            }

            trigger OnPreDataItem()
            begin
                if StartDate = 0D then
                    Error('Please enter a Start Date.');

                if EndDate = 0D then
                    Error('Please enter an End Date.');

                if StartDate > EndDate then
                    Error('Start Date cannot be greater than End Date.');
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(TotalQty);
                Clear(TotalAmount);
                Clear(TotalProfit);

                // Calculate current available inventory
                CalcFields(Inventory);

                // Calculate sales quantity and sales amount
                CalcSales();

                // Calculate profit
                CalcProfit();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Period)
                {
                    Caption = 'Report Period';

                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }

                    field(EndDateField; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                }
            }
        }
    }

    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";

        StartDate: Date;
        EndDate: Date;

        TotalQty: Decimal;
        TotalAmount: Decimal;
        TotalProfit: Decimal;

    // ---------------------------------------------------------
    // Calculate Sales Quantity and Sales Amount
    // ---------------------------------------------------------
    local procedure CalcSales()
    begin
        TotalQty := 0;
        TotalAmount := 0;

        // -----------------------------------------------------
        // Sales Quantity
        // -----------------------------------------------------
        ItemLedgEntry.Reset();

        ItemLedgEntry.SetRange(
            "Item No.",
            Item."No.");

        ItemLedgEntry.SetRange(
            "Entry Type",
            ItemLedgEntry."Entry Type"::Sale);

        ItemLedgEntry.SetRange(
            "Posting Date",
            StartDate,
            EndDate);

        ItemLedgEntry.CalcSums(Quantity);

        // Sales quantities are normally stored as negative
        // quantities in the Item Ledger Entry.
        // Display sales quantity as positive.
        TotalQty := -ItemLedgEntry.Quantity;

        // -----------------------------------------------------
        // Sales Amount
        // -----------------------------------------------------
        ValueEntry.Reset();

        ValueEntry.SetRange(
            "Item No.",
            Item."No.");

        ValueEntry.SetRange(
            "Posting Date",
            StartDate,
            EndDate);

        ValueEntry.SetRange(
            "Item Ledger Entry Type",
            ValueEntry."Item Ledger Entry Type"::Sale);

        ValueEntry.CalcSums(
            "Sales Amount (Actual)");

        TotalAmount := ValueEntry."Sales Amount (Actual)";
    end;

    // ---------------------------------------------------------
    // Calculate Profit
    // ---------------------------------------------------------
    local procedure CalcProfit()
    var
        SalesAmount: Decimal;
        CostAmount: Decimal;
    begin
        SalesAmount := 0;
        CostAmount := 0;

        ValueEntry.Reset();

        ValueEntry.SetRange(
            "Item No.",
            Item."No.");

        ValueEntry.SetRange(
            "Posting Date",
            StartDate,
            EndDate);

        ValueEntry.SetRange(
            "Item Ledger Entry Type",
            ValueEntry."Item Ledger Entry Type"::Sale);

        ValueEntry.CalcSums(
            "Sales Amount (Actual)",
            "Cost Amount (Actual)");

        SalesAmount := ValueEntry."Sales Amount (Actual)";
        CostAmount := ValueEntry."Cost Amount (Actual)";

        // Cost Amount (Actual) for sales is normally negative.
        // Therefore:
        // Profit = Sales Amount + Cost Amount
        TotalProfit := SalesAmount + CostAmount;
    end;
}

