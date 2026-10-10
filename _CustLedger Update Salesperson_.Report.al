// report 50703 "CustLedger Update Salesperson"
// {
//     ApplicationArea = All;
//     Caption = 'Customer Ledger - Update Salesperson';
//     ProcessingOnly = true;
//     UsageCategory = ReportsAndAnalysis;

//     dataset
//     {
//         dataitem(CLE; "Cust. Ledger Entry")
//         {
//             DataItemTableView = sorting("Customer No.", "Posting Date") where("Salesperson Code" = filter(''));
//             RequestFilterFields = "Customer No.", "Posting Date", "Salesperson Code";

//             trigger OnAfterGetRecord()
//             begin
//                 ProcessEntry();
//             end;
//         }
//     }
//     requestpage
//     {
//         SaveValues = true;

//         layout
//         {
//             area(Content)
//             {
//                 field(UpdateRecords; UpdateRecords)
//                 {
//                     Caption = 'Update Salesperson Code on Cust. Ledger Entry';
//                     ToolTip = 'If enabled, mismatched entries are actually updated. If disabled, this is a preview-only report.';
//                 }
//             }
//         }
//     }
//     trigger OnPreReport()
//     begin
//         TempExcelBuffer.Reset();
//         TempExcelBuffer.DeleteAll();
//         WriteReportHeader();
//         if UpdateRecords then if not Confirm(ConfirmUpdateQst, false) then Error(UpdateCancelledErr);
//     end;

//     trigger OnPostReport()
//     begin
//         TempExcelBuffer.CreateNewBook(WorksheetNameLbl);
//         TempExcelBuffer.WriteSheet(WorksheetNameLbl, CompanyName, UserId);
//         TempExcelBuffer.CloseBook();
//         TempExcelBuffer.SetFriendlyFilename(ExcelFileNameLbl);
//         TempExcelBuffer.OpenExcel();
//         if UpdateRecords then
//             Message(UpdateSummaryMsg, UpdatedCount, MismatchCount)
//         else
//             Message(PreviewSummaryMsg, MismatchCount);
//     end;

//     var
//         TempExcelBuffer: Record "Excel Buffer" temporary;
//         Customer: Record Customer;
//         SalespersonPurchaser: Record "Salesperson/Purchaser";
//         UpdateRecords: Boolean;
//         MismatchCount: Integer;
//         UpdatedCount: Integer;
//         ExcelFileNameLbl: Label 'Cust Ledger Salesperson Update';
//         WorksheetNameLbl: Label 'Salesperson Update';
//         ConfirmUpdateQst: Label 'This will permanently update the Salesperson Code on all mismatched Cust. Ledger Entries in the current filter. Continue?';
//         UpdateCancelledErr: Label 'Update cancelled by user.';
//         UpdateSummaryMsg: Label '%1 entries updated out of %2 mismatches found.';
//         PreviewSummaryMsg: Label '%1 mismatches found. No records were updated (preview mode).';

//     local procedure ProcessEntry()
//     var
//         CustomerSalespersonCode: Code[20];
//         SalespersonName: Text[100];
//     begin
//         if not Customer.Get(CLE."Customer No.") then exit;
//         CustomerSalespersonCode := Customer."Salesperson Code";
//         if CustomerSalespersonCode = CLE."Salesperson Code" then exit;
//         MismatchCount += 1;
//         SalespersonName := GetSalespersonName(CustomerSalespersonCode);
//         WriteBodyLine(CustomerSalespersonCode, SalespersonName);
//         if UpdateRecords then begin
//             CLE."Salesperson Code" := CustomerSalespersonCode;
//             CLE.Modify();
//             UpdatedCount += 1;
//         end;
//     end;

//     local procedure GetSalespersonName(SalespersonCode: Code[20]): Text[100]
//     begin
//         if SalespersonCode = '' then exit('');
//         if SalespersonPurchaser.Get(SalespersonCode) then exit(SalespersonPurchaser.Name);
//         exit('');
//     end;

//     local procedure WriteReportHeader()
//     begin
//         TempExcelBuffer.NewRow();
//         AddTextCell('Customer No.', true);
//         AddTextCell('Customer Name', true);
//         AddTextCell('CLE Entry No.', true);
//         AddTextCell('Document No.', true);
//         AddTextCell('Posting Date', true);
//         AddTextCell('Old Salesperson Code', true);
//         AddTextCell('New Salesperson Code', true);
//         AddTextCell('New Salesperson Name', true);
//         AddTextCell('Updated?', true);
//     end;

//     local procedure WriteBodyLine(NewCode: Code[20]; NewName: Text[100])
//     begin
//         TempExcelBuffer.NewRow();
//         AddTextCell(CLE."Customer No.", false);
//         AddTextCell(Customer.Name, false);
//         AddTextCell(Format(CLE."Entry No."), false);
//         AddTextCell(CLE."Document No.", false);
//         AddTextCell(Format(CLE."Posting Date"), false);
//         AddTextCell(CLE."Salesperson Code", false);
//         AddTextCell(NewCode, false);
//         AddTextCell(NewName, false);
//         AddTextCell(FormatYesNo(UpdateRecords), false);
//     end;

//     local procedure FormatYesNo(Value: Boolean): Text
//     begin
//         if Value then exit('Yes');
//         exit('No');
//     end;

//     local procedure AddTextCell(CellValue: Text; IsBold: Boolean)
//     begin
//         TempExcelBuffer.AddColumn(CellValue, false, '', IsBold, false, false, '', TempExcelBuffer."Cell Type"::Text);
//     end;
// }
