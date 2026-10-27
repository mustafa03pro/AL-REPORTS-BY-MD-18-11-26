
report 50262 "Daily Scanner Consumption"
{
    Caption = 'Daily Scanner Consumption Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Location Code", "Item No.";

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please select a Posting Date.');

                SetRange("Posting Date", PostingDate);
                SetRange("Entry Type", "Entry Type"::"Negative Adjmt.");
                SetFilter("Document No.", 'SCAN*');
            end;


            // trigger OnAfterGetRecord()
            // begin
            //     if FirstEntry then begin
            //         WriteHeaders();
            //         FirstEntry := false;
            //     end;

            //     ExcelBuffer.NewRow();
            //     AddText(Format(ItemLedgerEntry."Posting Date"));
            //     AddText(Format(ItemLedgerEntry."Entry Type"));
            //     AddText(Format(ItemLedgerEntry."Document Type"));
            //     AddText(ItemLedgerEntry."Document No.");
            //     AddText(ItemLedgerEntry."Item No.");
            //     AddText(ItemLedgerEntry.Description);
            //     AddText(ItemLedgerEntry."Location Code");
            //     AddText(ItemLedgerEntry."Unit of Measure Code");
            //     AddText(Format(ItemLedgerEntry.Quantity));
            //     AddText(''); // Secondary Unit Code - map your custom field here.
            //     AddText(''); // Quantity in Secondary UOM - map your custom calculation here.
            //     AddText(Format(ItemLedgerEntry."Invoiced Quantity"));
            //     AddText(Format(ItemLedgerEntry."Remaining Quantity"));
            //     AddText(''); // Reserved Quantity - map a valid source if available.
            //     AddText(Format(ItemLedgerEntry."Sales Amount (Actual)"));
            //     AddText(Format(ItemLedgerEntry."Cost Amount (Actual)"));
            //     AddText(Format(ItemLedgerEntry."Cost Amount (Non-Invtbl.)"));
            //     AddText(Format(ItemLedgerEntry.Open));
            //     AddText(Format(ItemLedgerEntry."Order Type"));
            //     AddText(Format(ItemLedgerEntry."Entry No."));
            //     AddText(GetCreatedByUser(ItemLedgerEntry.SystemCreatedBy));
            //     AddText(ItemLedgerEntry."Source No.");
            // end;
            trigger OnAfterGetRecord()
            begin
                ItemLedgerEntry.CalcFields(
                    "Cost Amount (Actual)",
                    "Cost Amount (Non-Invtbl.)");

                if FirstEntry then begin
                    WriteHeaders();
                    FirstEntry := false;
                end;

                ExcelBuffer.NewRow();
                AddText(Format(ItemLedgerEntry."Posting Date"));
                AddText(Format(ItemLedgerEntry."Entry Type"));
                AddText(Format(ItemLedgerEntry."Document Type"));
                AddText(ItemLedgerEntry."Document No.");
                AddText(ItemLedgerEntry."Item No.");
                AddText(ItemLedgerEntry.Description);
                AddText(ItemLedgerEntry."Location Code");
                AddText(ItemLedgerEntry."Unit of Measure Code");
                AddText(Format(ItemLedgerEntry.Quantity));
                AddText('');
                AddText('');
                AddText(Format(ItemLedgerEntry."Invoiced Quantity"));
                AddText(Format(ItemLedgerEntry."Remaining Quantity"));
                AddText('');
                AddText(Format(ItemLedgerEntry."Sales Amount (Actual)"));
                AddText(Format(ItemLedgerEntry."Cost Amount (Actual)"));
                AddText(Format(ItemLedgerEntry."Cost Amount (Non-Invtbl.)"));
                AddText(Format(ItemLedgerEntry.Open));
                AddText(Format(ItemLedgerEntry."Order Type"));
                AddText(Format(ItemLedgerEntry."Entry No."));
                AddText(GetCreatedByUser(ItemLedgerEntry.SystemCreatedBy));
                AddText(ItemLedgerEntry."Source No.");
            end;


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
                    Caption = 'Report Filters';

                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Select the date for which scanner negative adjustments should be displayed.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error('Please select a Posting Date.');

        FirstEntry := true;
        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddText('DAILY DIRECT CONSUMPTION REPORT');
        ExcelBuffer.NewRow();
        AddText('Posting Date: ' + Format(PostingDate));
    end;

    trigger OnPostReport()
    begin
        if FirstEntry then
            Error(
                'No scanner negative adjustments were found for %1. Check the date and SCAN document number filter.',
                PostingDate);

        ExcelBuffer.CreateNewBook('Daily Consumption');
        ExcelBuffer.WriteSheet(
            'Daily Consumption',
            CompanyName(),
            UserId());
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('Daily_Scanner_Consumption');
        ExcelBuffer.OpenExcel();
    end;

    var
        PostingDate: Date;
        ExcelBuffer: Record "Excel Buffer" temporary;
        FirstEntry: Boolean;

    local procedure WriteHeaders()
    begin
        ExcelBuffer.NewRow();
        AddText('Posting Date');
        AddText('Entry Type');
        AddText('Document Type');
        AddText('Document No.');
        AddText('Item No.');
        AddText('Description');
        AddText('Location Code');
        AddText('Unit of Measure Code');
        AddText('Quantity');
        AddText('Secondary Unit Code');
        AddText('Quantity in Secondary UOM');
        AddText('Invoiced Quantity');
        AddText('Remaining Quantity');
        AddText('Reserved Quantity');
        AddText('Sales Amount (Actual)');
        AddText('Cost Amount (Actual)');
        AddText('Cost Amount (Non-Invtbl.)');
        AddText('Open');
        AddText('Order Type');
        AddText('Entry No.');
        AddText('Created By User');
        AddText('Source No.');
    end;

    local procedure AddText(Value: Text)
    begin
        ExcelBuffer.AddColumn(
            Value,
            false,
            '',
            false,
            false,
            false,
            '',
            ExcelBuffer."Cell Type"::Text);
    end;

    local procedure GetCreatedByUser(SystemCreatedBy: Guid): Code[50]
    var
        UserRec: Record User;
    begin
        if UserRec.Get(SystemCreatedBy) then
            exit(UserRec."User Name");

        exit('');
    end;
}
