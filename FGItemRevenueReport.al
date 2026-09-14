// report 50207 "FG Item Revenue Report"
// {
//     UsageCategory = ReportsAndAnalysis;
//     ApplicationArea = All;
//     Caption = 'Finished Goods - Quantity, Amount & Revenue';
//     DefaultLayout = RDLC;
//     RDLCLayout = './FGItemRevenueReport.rdlc';

//     dataset
//     {
//         dataitem(Item; Item)
//         {
//             RequestFilterFields = "No.", "Item Category Code";

//             column(No_Item; "No.") { }
//             column(Description_Item; Description) { }
//             column(ItemCategoryCode; "Item Category Code") { }
//             column(TotalQty; TotalQty) { }
//             column(TotalAmount; TotalAmount) { }
//             column(TotalRevenue; TotalRevenue) { }
//             column(SalesAccountNo; GLAccNo) { }

//             trigger OnPreDataItem()
//             begin
//                 // Show only Finished Goods items
//                 SetRange("Item Category Code", 'FG');
//             end;

//             trigger OnAfterGetRecord()
//             begin
//                 Clear(TotalQty);
//                 Clear(TotalAmount);
//                 Clear(TotalRevenue);
//                 Clear(GLAccNo);

//                 CalcQuantitySold();
//                 CalcSalesAmount();
//                 CalcRevenueFromGL();
//             end;
//         }
//     }

//     var
//         ItemLedgEntry: Record "Item Ledger Entry";
//         ValueEntry: Record "Value Entry";
//         GLEntry: Record "G/L Entry";
//         GenPostingSetup: Record "General Posting Setup";
//         TotalQty: Decimal;
//         TotalAmount: Decimal;
//         TotalRevenue: Decimal;
//         GLAccNo: Code[20];

//     // Quantity sold from Item Ledger Entry
//     local procedure CalcQuantitySold()
//     begin
//         ItemLedgEntry.Reset();
//         ItemLedgEntry.SetRange("Item No.", Item."No.");
//         ItemLedgEntry.SetRange(
//             "Entry Type",
//             ItemLedgEntry."Entry Type"::Sale);

//         ItemLedgEntry.CalcSums(Quantity);

//         // Sale quantities are normally stored as negative
//         TotalQty := -ItemLedgEntry.Quantity;
//     end;

//     // Sales amount from Value Entry
//     local procedure CalcSalesAmount()
//     begin
//         ValueEntry.Reset();
//         ValueEntry.SetRange("Item No.", Item."No.");
//         ValueEntry.SetRange(
//             "Item Ledger Entry Type",
//             ValueEntry."Item Ledger Entry Type"::Sale);

//         ValueEntry.CalcSums("Sales Amount (Actual)");

//         // Sales amounts are normally stored as negative
//         TotalAmount := -ValueEntry."Sales Amount (Actual)";
//     end;

//     // Revenue from the G/L account
//     local procedure CalcRevenueFromGL()
//     begin
//         TotalRevenue := 0;
//         GLAccNo := GetSalesAccountForItem(Item);

//         if GLAccNo = '' then
//             exit;

//         GLEntry.Reset();
//         GLEntry.SetRange("G/L Account No.", GLAccNo);
//         GLEntry.CalcSums(Amount);

//         // Revenue accounts normally have credit balances (negative Amount)
//         TotalRevenue := -GLEntry.Amount;
//     end;

//     // Get the Sales Account from General Posting Setup
//     local procedure GetSalesAccountForItem(Itm: Record Item): Code[20]
//     begin
//         GenPostingSetup.Reset();
//         GenPostingSetup.SetRange(
//             "Gen. Prod. Posting Group",
//             Itm."Gen. Prod. Posting Group");

//         // First try the blank/default Gen. Bus. Posting Group
//         GenPostingSetup.SetRange("Gen. Bus. Posting Group", '');

//         if GenPostingSetup.FindFirst() then
//             exit(GenPostingSetup."Sales Account");

//         // If no blank setup exists, use any matching setup
//         GenPostingSetup.SetRange("Gen. Bus. Posting Group");

//         if GenPostingSetup.FindFirst() then
//             exit(GenPostingSetup."Sales Account");

//         exit('');
//     end;
// }


// report 50207 "FG Item Revenue Report"
// {
//     UsageCategory = ReportsAndAnalysis;
//     ApplicationArea = All;
//     Caption = 'Finished Goods Revenue Report';

//     DefaultLayout = RDLC;
//     RDLCLayout = './FGItemRevenueReport.rdlc';

//     dataset
//     {
//         dataitem(Item; Item)
//         {
//             RequestFilterFields = "No.";

//             column(No_Item; "No.") { }
//             column(Description_Item; Description) { }
//             column(BaseUnitOfMeasure; "Base Unit of Measure") { }
//             column(Inventory; Inventory) { }

//             column(TotalQty; TotalQty) { }
//             column(TotalAmount; TotalAmount) { }
//             column(TotalRevenue; TotalRevenue) { }

//             trigger OnPreDataItem()
//             begin
//                 // Finished Goods Item Numbers start with FG/
//                 SetFilter("No.", 'FG/*');
//             end;

//             trigger OnAfterGetRecord()
//             begin
//                 Clear(TotalQty);
//                 Clear(TotalAmount);
//                 Clear(TotalRevenue);

//                 CalcQuantitySold();
//                 CalcSalesAmount();

//                 // Revenue equals Sales Amount for item-wise reporting
//                 TotalRevenue := TotalAmount;
//             end;
//         }
//     }

//     var
//         ItemLedgEntry: Record "Item Ledger Entry";
//         ValueEntry: Record "Value Entry";

//         TotalQty: Decimal;
//         TotalAmount: Decimal;
//         TotalRevenue: Decimal;


//     local procedure CalcQuantitySold()
//     begin
//         ItemLedgEntry.Reset();

//         ItemLedgEntry.SetRange("Item No.", Item."No.");
//         ItemLedgEntry.SetRange(
//             "Entry Type",
//             ItemLedgEntry."Entry Type"::Sale);

//         ItemLedgEntry.CalcSums(Quantity);

//         // Sale quantities are stored as negative
//         TotalQty := -ItemLedgEntry.Quantity;
//     end;


//     local procedure CalcSalesAmount()
//     begin
//         ValueEntry.Reset();

//         ValueEntry.SetRange("Item No.", Item."No.");
//         ValueEntry.SetRange(
//             "Item Ledger Entry Type",
//             ValueEntry."Item Ledger Entry Type"::Sale);

//         ValueEntry.CalcSums("Sales Amount (Actual)");

//         // Sales amounts are normally negative
//         TotalAmount := -ValueEntry."Sales Amount (Actual)";
//     end;
// }


report 50207 "FG Item Revenue Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Finished Goods - Quantity, Amount & Revenue';

    DefaultLayout = RDLC;
    RDLCLayout = './ReportLayouts/FGItemRevenueReport.rdlc';

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

            column(GenProdPostingGroup; "Gen. Prod. Posting Group")
            {
            }

            column(StartDate_Report; StartDate)
            {
            }

            column(EndDate_Report; EndDate)
            {
            }

            column(TotalQty; TotalQty)
            {
            }

            column(TotalAmount; TotalAmount)
            {
            }

            column(TotalRevenue; TotalRevenue)
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
                Clear(TotalRevenue);

                CalcQuantitySold();
                CalcItemRevenue();

                TotalRevenue := TotalAmount;
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
        TotalRevenue: Decimal;

    // ---------------------------------------------------------
    // Quantity Sold
    // ---------------------------------------------------------
    local procedure CalcQuantitySold()
    begin
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

        // Sales are stored as negative quantity
        // Display positive quantity in report
        TotalQty := -ItemLedgEntry.Quantity;
    end;

    // ---------------------------------------------------------
    // Item-Level Revenue
    // ---------------------------------------------------------
    local procedure CalcItemRevenue()
    begin
        ValueEntry.Reset();

        ValueEntry.SetRange(
            "Item No.",
            Item."No.");

        ValueEntry.SetRange(
            "Posting Date",
            StartDate,
            EndDate);

        ValueEntry.CalcSums(
            "Sales Amount (Actual)");

        // Item-specific sales amount
        TotalAmount := ValueEntry."Sales Amount (Actual)";
    end;
}