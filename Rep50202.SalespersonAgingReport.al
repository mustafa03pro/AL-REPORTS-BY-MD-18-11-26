report 50202 "Salesperson Aging Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Salesperson Outstanding Balance Report';
    DefaultLayout = RDLC;
    RDLCLayout = './ReportLayouts/SalespersonAgingReport.rdlc';

    dataset
    {
        dataitem(Salesperson; "Salesperson/Purchaser")
        {
            RequestFilterFields = Code;

            column(Salesperson_Code; Code)
            {
                Caption = 'Salesperson Code';
            }

            column(Salesperson_Name; Name)
            {
                Caption = 'Salesperson Name';
            }

            column(AsOfDate_Header; AsOfDate)
            {
                Caption = 'Aged As Of Date';
            }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Salesperson Code" = FIELD(Code);

                DataItemTableView =
                    SORTING("Salesperson Code", "Posting Date");

                column(Customer_No; "Customer No.")
                {
                    Caption = 'Customer No.';
                }

                column(Document_No; "Document No.")
                {
                    Caption = 'Document No.';
                }

                column(Posting_Date; "Posting Date")
                {
                    Caption = 'Posting Date';
                }

                column(Due_Date; "Due Date")
                {
                    Caption = 'Due Date';
                }

                column(Remaining_Amount; RemainingAmountLCY)
                {
                    Caption = 'Outstanding Amount';
                }

                column(Days_Overdue; DaysOverdue)
                {
                    Caption = 'Age Days';
                }

                column(Age_Bucket; AgeBucket)
                {
                    Caption = 'Age Bucket';
                }

                column(Age_Bucket_Sort; AgeBucketSort)
                {
                    Caption = 'Age Bucket Sort';
                }

                trigger OnPreDataItem()
                begin
                    // Only ledger entries posted on or before
                    // the selected As-Of Date.
                    SetRange("Posting Date", 0D, AsOfDate);
                end;

                trigger OnAfterGetRecord()
                var
                    DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                begin
                    RemainingAmountLCY := 0;

                    // ------------------------------------------------
                    // Calculate remaining amount AS OF AsOfDate
                    // ------------------------------------------------
                    //
                    // We cannot simply use:
                    //
                    // "Remaining Amt. (LCY)"
                    //
                    // because that represents the CURRENT
                    // remaining balance and can include applications
                    // made after the selected As-Of Date.
                    //
                    // Therefore, rebuild the balance using
                    // Detailed Customer Ledger Entries up to
                    // the selected As-Of Date.
                    // ------------------------------------------------

                    DetailedCustLedgEntry.Reset();

                    DetailedCustLedgEntry.SetRange(
                        "Cust. Ledger Entry No.",
                        "Entry No."
                    );

                    DetailedCustLedgEntry.SetRange(
                        "Posting Date",
                        0D,
                        AsOfDate
                    );

                    if DetailedCustLedgEntry.FindSet() then
                        repeat
                            RemainingAmountLCY +=
                                DetailedCustLedgEntry."Amount (LCY)";
                        until DetailedCustLedgEntry.Next() = 0;

                    // ------------------------------------------------
                    // Only show amounts that salesperson needs
                    // to collect.
                    // ------------------------------------------------

                    if RemainingAmountLCY <= 0 then
                        CurrReport.Skip();

                    // ------------------------------------------------
                    // IMPORTANT:
                    // AGE IS BASED ON POSTING DATE
                    // NOT DUE DATE
                    // ------------------------------------------------

                    if "Posting Date" <= AsOfDate then
                        DaysOverdue := AsOfDate - "Posting Date"
                    else
                        DaysOverdue := 0;

                    // ------------------------------------------------
                    // AGING BUCKETS
                    // ------------------------------------------------

                    case true of

                        DaysOverdue <= 15:
                            begin
                                AgeBucket := '0-15 Days';
                                AgeBucketSort := 1;
                            end;

                        DaysOverdue <= 30:
                            begin
                                AgeBucket := '16-30 Days';
                                AgeBucketSort := 2;
                            end;

                        DaysOverdue <= 45:
                            begin
                                AgeBucket := '31-45 Days';
                                AgeBucketSort := 3;
                            end;

                        DaysOverdue <= 60:
                            begin
                                AgeBucket := '46-60 Days';
                                AgeBucketSort := 4;
                            end;

                        DaysOverdue <= 90:
                            begin
                                AgeBucket := '61-90 Days';
                                AgeBucketSort := 5;
                            end;

                        DaysOverdue <= 120:
                            begin
                                AgeBucket := '91-120 Days';
                                AgeBucketSort := 6;
                            end;

                        DaysOverdue <= 180:
                            begin
                                AgeBucket := '121-180 Days';
                                AgeBucketSort := 7;
                            end;

                        DaysOverdue <= 365:
                            begin
                                AgeBucket := '181-365 Days';
                                AgeBucketSort := 8;
                            end;

                        else begin
                            AgeBucket := 'More than 365 Days';
                            AgeBucketSort := 9;
                        end;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Report Options';

                    field(AsOfDateField; AsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Aged As Of Date';
                        ToolTip =
                            'Select the date as of which the outstanding balance should be calculated.';
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
        DaysOverdue: Integer;
        AgeBucket: Text[30];
        AgeBucketSort: Integer;
        RemainingAmountLCY: Decimal;
}