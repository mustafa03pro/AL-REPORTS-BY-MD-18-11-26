namespace ALBCReportverify.ALBCReportverify;

using Microsoft.Sales.Customer;

report 50101 "Customer List Report"
{
    ApplicationArea = All;
    Caption = 'Customer List Report';
    UsageCategory = ReportsAndAnalysis;

    DefaultLayout = RDLC;
    RDLCLayout = 'ReportLayouts/CustomerListReport.rdlc';

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(City; City)
            {
            }
            column(Phone_No_; "Phone No.")
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
            }
        }

        actions
        {
            area(Processing)
            {
            }
        }
    }
}