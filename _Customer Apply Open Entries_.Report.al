// report 50704 "Customer Apply Open Entries"
// {
//     ApplicationArea = All;
//     Caption = 'Customer Apply Open Entries';
//     UsageCategory = ReportsAndAnalysis;
//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem(Customer; Customer)
//         {
//             RequestFilterFields = "No.";

//             trigger OnAfterGetRecord()
//             var
//                 CustomerLedger: Record "Cust. Ledger Entry";
//                 CustomerLedger1: Record "Cust. Ledger Entry";
//                 ApplyCustomerLedger: Record "Cust. Ledger Entry";
//                 ApplyCustomerLedger2: Record "Cust. Ledger Entry";
//                 CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
//                 CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
//                 I: Integer;
//                 ApplyUnapplyParameters: Record "Apply Unapply Parameters";
//                 GLSetup: Record "General Ledger Setup";
//                 InvoiceAmt: Decimal;
//                 AmountToApply: Decimal;
//                 AmtApplied: Decimal;
//                 ApplicationDate: Date;
//             begin
//                 ApplyCustomerLedger.Reset();
//                 ApplyCustomerLedger.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                 ApplyCustomerLedger.SetRange("Customer No.", Customer."No.");
//                 ApplyCustomerLedger.SetAscending("Posting Date", true);
//                 if ApplyCustomerLedger.FindSet() then begin
//                     Repeat
//                         ApplyCustomerLedger.CalcFields("Remaining Amount");
//                         IF ApplyCustomerLedger."Remaining Amount" <> 0 then begin
//                             ApplyCustomerLedger.Open := true;
//                             ApplyCustomerLedger."Amount to Apply" := 0;
//                             ApplyCustomerLedger."Applies-to ID" := '';
//                             ApplyCustomerLedger.Modify();
//                         end;
//                     Until ApplyCustomerLedger.Next() = 0
//                 End;
//                 Commit();
//                 CustomerLedger.Reset();
//                 CustomerLedger.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                 CustomerLedger.SetRange("Customer No.", Customer."No.");
//                 CustomerLedger.SetRange("Posting Date", StartDate, EndDate);
//                 CustomerLedger.SetFilter("Source Code", '<>%1', 'TDS');
//                 CustomerLedger.SetRange(Open, true);
//                 CustomerLedger.SetAscending("Posting Date", true);
//                 if CustomerLedger.FindSet() then begin
//                     repeat
//                         CustomerLedger.CalcFields("Remaining Amount");
//                         if CustomerLedger."Remaining Amount" <> 0 then begin
//                             ApplyCustomerLedger.Reset();
//                             ApplyCustomerLedger.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                             ApplyCustomerLedger.SetRange("Customer No.", Customer."No.");
//                             ApplyCustomerLedger.SetRange("Posting Date", StartDate, EndDate);
//                             ApplyCustomerLedger.SetFilter("Source Code", '<>%1', 'TDS');
//                             ApplyCustomerLedger.SetRange(Positive, Not CustomerLedger.Positive);
//                             ApplyCustomerLedger.SetAutoCalcFields("Remaining Amount");
//                             ApplyCustomerLedger.SetAscending("Posting Date", true);
//                             if ApplyCustomerLedger.FindSet() then begin
//                                 Repeat
//                                     ApplyCustomerLedger.CalcFields("Remaining Amount");
//                                     IF ApplyCustomerLedger."Remaining Amount" = 0 then begin
//                                         ApplyCustomerLedger.Open := false;
//                                         ApplyCustomerLedger."Applies-to ID" := '';
//                                         ApplyCustomerLedger."Amount to Apply" := 0;
//                                         ApplyCustomerLedger.Modify();
//                                     end;
//                                 Until ApplyCustomerLedger.Next() = 0
//                             End;
//                             CustomerLedger.CalcFields("Remaining Amount");
//                             if (CustomerLedger."Remaining Amount" <> 0) then begin
//                                 ApplyCustomerLedger.Reset();
//                                 ApplyCustomerLedger.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                                 ApplyCustomerLedger.SetRange("Customer No.", Customer."No.");
//                                 ApplyCustomerLedger.SetRange("Posting Date", StartDate, EndDate);
//                                 ApplyCustomerLedger.SetFilter("Source Code", '<>%1', 'TDS');
//                                 ApplyCustomerLedger.SetRange(Open, true);
//                                 ApplyCustomerLedger.SetRange(Positive, Not CustomerLedger.Positive);
//                                 ApplyCustomerLedger.SetFilter("Entry No.", '<>%1', CustomerLedger."Entry No.");
//                                 ApplyCustomerLedger.SetAscending("Posting Date", true);
//                                 if ApplyCustomerLedger.FindSet() then begin
//                                     Repeat
//                                         CustomerLedger.CalcFields("Remaining Amount");
//                                         if 0 <> CustomerLedger."Remaining Amount" then begin
//                                             ApplyCustomerLedger.CalcFields("Remaining Amount");
//                                             if ApplyCustomerLedger."Remaining Amount" <> 0 then begin
//                                                 ApplyCustomerLedger.Validate("Applies-to ID", UserId);
//                                                 ApplyCustomerLedger."Accepted Pmt. Disc. Tolerance" := false;
//                                                 ApplyCustomerLedger."Accepted Payment Tolerance" := 0;
//                                                 ApplyCustomerLedger.CalcFields("Remaining Amount");
//                                                 ApplyCustomerLedger."Amount to Apply" := ApplyCustomerLedger."Remaining Amount";
//                                                 if ApplyCustomerLedger."Entry No." = CustomerLedger."Entry No." then ApplyCustomerLedger."Applying Entry" := ApplyCustomerLedger."Applying Entry";
//                                                 ApplyCustomerLedger.modify();
//                                                 CustomerLedger.Validate("Applies-to ID", UserId);
//                                                 CustomerLedger."Accepted Pmt. Disc. Tolerance" := false;
//                                                 CustomerLedger."Accepted Payment Tolerance" := 0;
//                                                 CustomerLedger."Amount to Apply" := 0;
//                                                 //CustomerLedger."Applying Entry" := false;
//                                                 CustomerLedger.CalcFields("Remaining Amount");
//                                                 CustomerLedger."Amount to Apply" := CustomerLedger."Remaining Amount";
//                                                 if ApplyCustomerLedger."Entry No." = CustomerLedger."Entry No." then CustomerLedger."Applying Entry" := ApplyCustomerLedger."Applying Entry";
//                                                 CustomerLedger.modify();
//                                                 ApplyCustomerLedger2.Reset();
//                                                 ApplyCustomerLedger2.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                                                 ApplyCustomerLedger2.SetRange("Customer No.", Customer."No.");
//                                                 ApplyCustomerLedger2.SetRange("Posting Date", StartDate, EndDate);
//                                                 ApplyCustomerLedger2.SetFilter("Source Code", '<>%1', 'TDS');
//                                                 ApplyCustomerLedger2.SetRange(Positive, CustomerLedger.Positive);
//                                                 ApplyCustomerLedger2.SetFilter("Entry No.", '<>%1', CustomerLedger."Entry No.");
//                                                 ApplyCustomerLedger2.SetAscending("Posting Date", true);
//                                                 if ApplyCustomerLedger2.FindSet() then begin
//                                                     Repeat
//                                                         ApplyCustomerLedger2."Applies-to ID" := '';
//                                                         ApplyCustomerLedger2."Amount to Apply" := 0;
//                                                         //ApplyCustomerLedger2.Open := true;
//                                                         ApplyCustomerLedger2.Modify();
//                                                     Until ApplyCustomerLedger2.Next() = 0
//                                                 End;
//                                                 Clear(ApplyUnapplyParameters);
//                                                 ApplyUnapplyParameters.CopyFromCustLedgEntry(CustomerLedger);
//                                                 GLSetup.GetRecordOnce();
//                                                 ApplyUnapplyParameters."Posting Date" := 0D;
//                                                 if GLSetup."Journal Templ. Name Mandatory" then begin
//                                                     GLSetup.TestField("Apply Jnl. Template Name");
//                                                     GLSetup.TestField("Apply Jnl. Batch Name");
//                                                     ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
//                                                     ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
//                                                 end;
//                                                 if CustEntryApplyPostedEntries.Apply(CustomerLedger, ApplyUnapplyParameters) then;
//                                                 ApplyCustomerLedger2.Reset();
//                                                 ApplyCustomerLedger2.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                                                 ApplyCustomerLedger2.SetRange("Customer No.", Customer."No.");
//                                                 ApplyCustomerLedger2.SetRange("Posting Date", StartDate, EndDate);
//                                                 ApplyCustomerLedger2.SetFilter("Source Code", '<>%1', 'TDS');
//                                                 ApplyCustomerLedger2.SetAscending("Posting Date", true);
//                                                 if ApplyCustomerLedger2.FindSet() then begin
//                                                     Repeat
//                                                         ApplyCustomerLedger2.CalcFields("Remaining Amount");
//                                                         IF ApplyCustomerLedger2."Remaining Amount" = 0 then begin
//                                                             ApplyCustomerLedger2.Open := false;
//                                                             ApplyCustomerLedger2."Applies-to ID" := '';
//                                                             ApplyCustomerLedger2."Amount to Apply" := 0;
//                                                             ApplyCustomerLedger2.Modify();
//                                                         end;
//                                                     Until ApplyCustomerLedger2.Next() = 0
//                                                 End;
//                                             end
//                                             else begin
//                                                 ApplyCustomerLedger.CalcFields("Remaining Amount");
//                                                 IF ApplyCustomerLedger."Remaining Amount" = 0 then begin
//                                                     ApplyCustomerLedger.Open := false;
//                                                     ApplyCustomerLedger."Applies-to ID" := '';
//                                                     ApplyCustomerLedger."Amount to Apply" := 0;
//                                                     ApplyCustomerLedger.Modify();
//                                                 end;
//                                             end;
//                                         end;
//                                         Commit();
//                                     Until ApplyCustomerLedger.Next() = 0;
//                                 end;
//                             end;
//                             ApplyCustomerLedger2.Reset();
//                             ApplyCustomerLedger2.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                             ApplyCustomerLedger2.SetRange("Customer No.", Customer."No.");
//                             ApplyCustomerLedger2.SetRange("Posting Date", StartDate, EndDate);
//                             ApplyCustomerLedger2.SetFilter("Source Code", '<>%1', 'TDS');
//                             ApplyCustomerLedger2.SetAscending("Posting Date", true);
//                             if ApplyCustomerLedger2.FindSet() then begin
//                                 Repeat
//                                     ApplyCustomerLedger2.CalcFields("Remaining Amount");
//                                     IF ApplyCustomerLedger2."Remaining Amount" = 0 then begin
//                                         ApplyCustomerLedger2.Open := false;
//                                         ApplyCustomerLedger2."Applies-to ID" := '';
//                                         ApplyCustomerLedger2."Amount to Apply" := 0;
//                                         ApplyCustomerLedger2.Modify();
//                                     end;
//                                 Until ApplyCustomerLedger2.Next() = 0
//                             End;
//                             ApplyCustomerLedger.Reset();
//                             ApplyCustomerLedger.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
//                             ApplyCustomerLedger.SetRange("Customer No.", Customer."No.");
//                             ApplyCustomerLedger.SetRange("Posting Date", StartDate, EndDate);
//                             ApplyCustomerLedger.SetFilter("Source Code", '<>%1', 'TDS');
//                             ApplyCustomerLedger.SetRange(Open, true);
//                             ApplyCustomerLedger.SetRange(Positive, Not CustomerLedger.Positive);
//                             if ApplyCustomerLedger.FindSet() then begin
//                                 Repeat
//                                     ApplyCustomerLedger."Applies-to ID" := '';
//                                     ApplyCustomerLedger."Amount to Apply" := 0;
//                                     ApplyCustomerLedger.Modify();
//                                 Until ApplyCustomerLedger.Next() = 0
//                             End;
//                         end;
//                         Commit();
//                     until CustomerLedger.Next() = 0;
//                 End;
//             End;
//         }
//     }
//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 group(GroupName)
//                 {
//                     field(StartDate; StartDate)
//                     {
//                     }
//                     field(EndDate; EndDate)
//                     {
//                     }
//                 }
//             }
//         }
//         actions
//         {
//             area(processing)
//             {
//             }
//         }
//     }
//     trigger OnInitReport()
//     begin
//         GeneralLedgerSetup.Get();
//         //StartDate := GeneralLedgerSetup."NXN Start Date filter";
//         //EndDate := GeneralLedgerSetup."NXN End Date Filter";
//         //StartDate := 20220101D;
//         //EndDate := 20231201D;
//     end;

//     var
//         GeneralLedgerSetup: Record "General Ledger Setup";
//         StartDate: Date;
//         EndDate: Date;
// }
