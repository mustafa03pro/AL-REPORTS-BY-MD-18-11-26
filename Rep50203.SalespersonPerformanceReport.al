namespace ALBCReportverify.ALBCReportverify;

using Microsoft.Sales.Receivables;

report 50203 "Salesperson Performance Report"
{
    ApplicationArea = All;
    Caption = 'Salesperson Outstanding Report';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'ReportLayouts/SalespersonOutstandingReport.rdlc';

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = sorting("Salesperson Code", "Customer No.", "Posting Date")
                where("Remaining Amt. (LCY)" = filter(<> 0));

            RequestFilterFields = "Salesperson Code", "Customer No.", "Posting Date", "Due Date";

            column(CustomerName; "Customer Name")
            {
            }

            column(CustomerNo; "Customer No.")
            {
            }

            column(SalespersonCode; "Salesperson Code")
            {
            }

            column(DocumentDate; "Document Date")
            {
            }

            column(DocumentNo; "Document No.")
            {
            }

            column(PostingDate; "Posting Date")
            {
            }

            column(DueDate; "Due Date")
            {
            }

            column(RemainingAmtLCY; "Remaining Amt. (LCY)")
            {
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Filters';
                }
            }
        }
    }
}