

// page 50233 "Raw Material Transfer Scanner"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = Tasks;
//     Caption = 'Raw Material Transfer Scanner';

//     layout
//     {
//         area(content)
//         {
//             group(TransferDetails)
//             {
//                 Caption = 'Transfer Details';

//                 field(TransferDate; TransferDate)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer Date';

//                     trigger OnValidate()
//                     begin
//                         if TransferDate = 0D then
//                             Error('Transfer Date is required.');
//                     end;
//                 }

//                 field(RequestedBy; RequestedBy)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Requested By User';
//                     Editable = false;
//                 }

//                 field(SelectedFromLocation; SelectedFromLocation)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer-from Location';
//                     TableRelation = Location.Code;

//                     trigger OnValidate()
//                     begin
//                         if SelectedFromLocation <> '' then
//                             if SelectedFromLocation =
//                                SelectedToLocation
//                             then
//                                 Error(
//                                     'Source and destination locations must be different.');

//                         TempScanBuffer.Reset();
//                         TempScanBuffer.DeleteAll();

//                         CurrPage.ScanLines.Page.SetBuffer(
//                             TempScanBuffer);
//                         CurrPage.Update(false);
//                     end;
//                 }

//                 field(SelectedToLocation; SelectedToLocation)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer-to Location';
//                     TableRelation = Location.Code;

//                     trigger OnValidate()
//                     begin
//                         if SelectedToLocation <> '' then
//                             if SelectedToLocation =
//                                SelectedFromLocation
//                             then
//                                 Error(
//                                     'Source and destination locations must be different.');
//                     end;
//                 }

//                 //     field(SelectedInTransitCode; SelectedInTransitCode)
//                 //     {
//                 //         ApplicationArea = All;
//                 //         Caption = 'In-Transit Location';
//                 //         TableRelation = Location.Code;

//                 //         trigger OnValidate()
//                 //         var
//                 //             LocationRec: Record Location;
//                 //         begin
//                 //             if SelectedInTransitCode = '' then
//                 //                 exit;

//                 //             if SelectedInTransitCode =
//                 //                SelectedFromLocation
//                 //             then
//                 //                 Error(
//                 //                     'In-transit location must differ from source.');

//                 //             if SelectedInTransitCode =
//                 //                SelectedToLocation
//                 //             then
//                 //                 Error(
//                 //                     'In-transit location must differ from destination.');

//                 //             LocationRec.Get(SelectedInTransitCode);

//                 //             if not LocationRec."Use As In-Transit" then
//                 //                 Error(
//                 //                     'Location %1 is not configured as an in-transit location.',
//                 //                     SelectedInTransitCode);
//                 //         end;
//                 //     }
//             }

//             group(ScanGroup)
//             {
//                 Caption = 'Barcode Scanner';

//                 field(ScannedBarcode; ScannedBarcode)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Scan Barcode / GTIN';
//                     ToolTip =
//                         'Scan a barcode and press Enter to add the item.';
//                     QuickEntry = true;

//                     trigger OnValidate()
//                     begin
//                         if ScannedBarcode <> '' then begin
//                             ProcessBarcode(ScannedBarcode);
//                             Clear(ScannedBarcode);
//                             CurrPage.ScanLines.Page.SetBuffer(
//                                 TempScanBuffer);
//                             CurrPage.Update(false);
//                         end;
//                     end;
//                 }

//                 field(DefaultQty; DefaultQty)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Quantity per Scan';
//                     DecimalPlaces = 0 : 5;

//                     trigger OnValidate()
//                     begin
//                         if DefaultQty <= 0 then
//                             Error(
//                                 'Quantity per scan must be greater than zero.');
//                     end;
//                 }
//             }

//             part(ScanLines; "Transfer Scan Lines")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(CreateTransferOrderAction)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Create Transfer Order';
//                 Image = CreateDocument;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 ToolTip =
//                     'Create a standard transfer order from the scanned items.';

//                 trigger OnAction()
//                 begin
//                     CreateTransferOrder();
//                 end;
//             }

//             action(ClearScannedItems)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Clear Scanned Items';
//                 Image = ClearLog;

//                 trigger OnAction()
//                 begin
//                     if not Confirm(
//                         'Do you want to remove all scanned items?',
//                         false)
//                     then
//                         exit;

//                     TempScanBuffer.Reset();
//                     TempScanBuffer.DeleteAll();

//                     CurrPage.ScanLines.Page.SetBuffer(
//                         TempScanBuffer);

//                     CurrPage.Update(false);
//                 end;
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         TransferDate := WorkDate();
//         RequestedBy := CopyStr(UserId(), 1, MaxStrLen(RequestedBy));
//         DefaultQty := 1;

//         CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
//     end;

//     var
//         ScannedBarcode: Code[50];
//         SelectedFromLocation: Code[10];
//         SelectedToLocation: Code[10];
//         //  SelectedInTransitCode: Code[10];

//         TransferDate: Date;
//         RequestedBy: Code[50];
//         DefaultQty: Decimal;

//         TempScanBuffer: Record "Transfer Scan Buffer" temporary;

//     local procedure ProcessBarcode(BarcodeValue: Code[50])
//     var
//         Item: Record Item;
//         ItemReference: Record "Item Reference";
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         ItemNo: Code[20];
//         AvailableQty: Decimal;
//         RequestedQty: Decimal;
//         NextEntryNo: Integer;
//     begin
//         if SelectedFromLocation = '' then
//             Error('Select the source location before scanning.');

//         if SelectedToLocation = '' then
//             Error('Select the destination location before scanning.');

//         if SelectedFromLocation = SelectedToLocation then
//             Error(
//                 'Source and destination locations must be different.');

//         if TransferDate = 0D then
//             Error('Transfer Date is required.');

//         if DefaultQty <= 0 then
//             Error('Quantity per scan must be greater than zero.');

//         ItemNo := '';

//         // 1. Resolve barcode through Item Reference.
//         ItemReference.SetRange(
//             "Reference Type",
//             ItemReference."Reference Type"::"Bar Code");

//         ItemReference.SetRange("Reference No.", BarcodeValue);

//         if ItemReference.FindFirst() then
//             ItemNo := ItemReference."Item No.";

//         // 2. Fall back to the item's GTIN.
//         if ItemNo = '' then begin
//             if StrLen(BarcodeValue) <= MaxStrLen(Item.GTIN) then begin
//                 Item.SetRange(
//                     GTIN,
//                     CopyStr(
//                         BarcodeValue,
//                         1,
//                         MaxStrLen(Item.GTIN)));

//                 if Item.FindFirst() then
//                     ItemNo := Item."No.";
//             end;
//         end;

//         // 3. Fall back to direct Item No. scanning.
//         if ItemNo = '' then begin
//             if StrLen(BarcodeValue) <= MaxStrLen(Item."No.") then
//                 if Item.Get(
//                     CopyStr(
//                         BarcodeValue,
//                         1,
//                         MaxStrLen(Item."No.")))
//                 then
//                     ItemNo := Item."No.";
//         end;

//         if ItemNo = '' then
//             Error(
//                 'No item found for barcode/GTIN %1.',
//                 BarcodeValue);

//         Item.Get(ItemNo);

//         // 4. Only inventory items are eligible.
//         if Item.Type <> Item.Type::Inventory then
//             Error(
//                 'Item %1 must have Type = Inventory.',
//                 ItemNo);

//         if Item.Blocked then
//             Error('Item %1 is blocked.', ItemNo);

//         if Item."Base Unit of Measure" = '' then
//             Error(
//                 'Item %1 has no base unit of measure.',
//                 ItemNo);

//         // 5. Calculate on-hand stock at the source.
//         ItemLedgerEntry.Reset();
//         ItemLedgerEntry.SetRange("Item No.", ItemNo);
//         ItemLedgerEntry.SetRange(
//             "Location Code",
//             SelectedFromLocation);

//         ItemLedgerEntry.CalcSums("Remaining Quantity");

//         AvailableQty := ItemLedgerEntry."Remaining Quantity";

//         // 6. Accumulate repeated scans of the same item.
//         TempScanBuffer.Reset();
//         TempScanBuffer.SetRange("Item No.", ItemNo);

//         if TempScanBuffer.FindFirst() then begin
//             RequestedQty :=
//                 TempScanBuffer.Quantity + DefaultQty;

//             if RequestedQty > AvailableQty then
//                 Error(
//                     'Insufficient stock for item %1 at location %2. ' +
//                     'Available: %3; already requested: %4; ' +
//                     'additional scan: %5.',
//                     ItemNo,
//                     SelectedFromLocation,
//                     AvailableQty,
//                     TempScanBuffer.Quantity,
//                     DefaultQty);

//             TempScanBuffer.Quantity := RequestedQty;
//             TempScanBuffer.Barcode := BarcodeValue;
//             TempScanBuffer."Available Quantity" := AvailableQty;
//             TempScanBuffer.Modify();
//         end else begin
//             if DefaultQty > AvailableQty then
//                 Error(
//                     'Insufficient stock for item %1 at location %2. ' +
//                     'Available: %3; requested: %4.',
//                     ItemNo,
//                     SelectedFromLocation,
//                     AvailableQty,
//                     DefaultQty);

//             TempScanBuffer.Reset();

//             if TempScanBuffer.FindLast() then
//                 NextEntryNo := TempScanBuffer."Entry No." + 1
//             else
//                 NextEntryNo := 1;

//             TempScanBuffer.Init();
//             TempScanBuffer."Entry No." := NextEntryNo;
//             TempScanBuffer."Item No." := ItemNo;
//             TempScanBuffer.Description := Item.Description;
//             TempScanBuffer.Barcode := BarcodeValue;
//             TempScanBuffer.Quantity := DefaultQty;
//             TempScanBuffer."Unit of Measure Code" :=
//                 Item."Base Unit of Measure";
//             TempScanBuffer."Available Quantity" := AvailableQty;
//             TempScanBuffer.Insert();
//         end;
//     end;

//     local procedure CreateTransferOrder()
//     var
//         InventorySetup: Record "Inventory Setup";
//         TransferHeader: Record "Transfer Header";
//         TransferLine: Record "Transfer Line";
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         NoSeries: Codeunit "No. Series";
//         NewTransferNo: Code[20];
//         NextLineNo: Integer;
//         AvailableQty: Decimal;
//     begin
//         // 1. Validate mandatory header details.
//         if TransferDate = 0D then
//             Error('Transfer Date is required.');

//         if SelectedFromLocation = '' then
//             Error('Select the source location.');

//         if SelectedToLocation = '' then
//             Error('Select the destination location.');

//         if SelectedFromLocation = SelectedToLocation then
//             Error(
//                 'Source and destination locations must be different.');

//         TempScanBuffer.Reset();
//         if TempScanBuffer.IsEmpty() then
//             Error('Scan at least one item before creating a transfer.');

//         // 2. Revalidate source stock immediately before creation.
//         if TempScanBuffer.FindSet() then
//             repeat
//                 ItemLedgerEntry.Reset();
//                 ItemLedgerEntry.SetRange(
//                     "Item No.", TempScanBuffer."Item No.");
//                 ItemLedgerEntry.SetRange(
//                     "Location Code", SelectedFromLocation);
//                 ItemLedgerEntry.CalcSums("Remaining Quantity");

//                 AvailableQty := ItemLedgerEntry."Remaining Quantity";
//                 if TempScanBuffer.Quantity > AvailableQty then
//                     Error(
//                         'Stock has changed for item %1. Available: %2; requested: %3.',
//                         TempScanBuffer."Item No.",
//                         AvailableQty,
//                         TempScanBuffer.Quantity);
//             until TempScanBuffer.Next() = 0;

//         // 3. Get the standard Transfer Order number.
//         InventorySetup.Get();
//         InventorySetup.TestField("Transfer Order Nos.");
//         NewTransferNo := NoSeries.GetNextNo(
//             InventorySetup."Transfer Order Nos.", TransferDate);

//         // 4. Insert the header first so subsequent field validation
//         //    operates on an existing Transfer Header record.
//         TransferHeader.Init();
//         TransferHeader."No. Series" := InventorySetup."Transfer Order Nos.";
//         TransferHeader."No." := NewTransferNo;
//         TransferHeader."Requested By User ID" :=
//             CopyStr(UserId(), 1, MaxStrLen(TransferHeader."Requested By User ID"));
//         TransferHeader.Insert(true);

//         // 5. Set and validate the header fields.
//         TransferHeader.Validate("Transfer-from Code", SelectedFromLocation);
//         TransferHeader.Validate("Transfer-to Code", SelectedToLocation);

//         // Direct transfer avoids requiring an in-transit location.
//         TransferHeader.Validate("Direct Transfer", true);
//         TransferHeader.Validate("Posting Date", TransferDate);
//         TransferHeader.Validate("Shipment Date", TransferDate);
//         TransferHeader.Validate("Receipt Date", TransferDate);
//         TransferHeader.Modify(true);

//         // 6. Create standard Transfer Lines.
//         NextLineNo := 10000;
//         TempScanBuffer.Reset();
//         if TempScanBuffer.FindSet() then
//             repeat
//                 TransferLine.Init();
//                 TransferLine."Document No." := TransferHeader."No.";
//                 TransferLine."Line No." := NextLineNo;
//                 TransferLine.Validate("Item No.", TempScanBuffer."Item No.");
//                 TransferLine.Validate(
//                     "Unit of Measure Code", TempScanBuffer."Unit of Measure Code");
//                 TransferLine.Validate(Quantity, TempScanBuffer.Quantity);
//                 TransferLine.Insert(true);
//                 NextLineNo += 10000;
//             until TempScanBuffer.Next() = 0;

//         // The transfer is created but not posted by this scanner.
//         Message(
//             'Transfer Order %1 has been created with %2 scanned item line(s). Shipment and receipt have not been posted.',
//             TransferHeader."No.",
//             CountScannedLines());

//         // Clear the scanner buffer only after successful creation.
//         TempScanBuffer.Reset();
//         TempScanBuffer.DeleteAll();
//         Clear(ScannedBarcode);
//         CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
//         CurrPage.Update(false);
//     end;

//     local procedure CountScannedLines(): Integer
//     begin
//         TempScanBuffer.Reset();
//         exit(TempScanBuffer.Count());
//     end;
// }



// page 50233 "Raw Material Transfer Scanner"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = Tasks;
//     Caption = 'Raw Material Transfer Scanner';

//     layout
//     {
//         area(content)
//         {
//             group(TransferDetails)
//             {
//                 Caption = 'Transfer Details';

//                 field(TransferDate; TransferDate)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer Date';

//                     trigger OnValidate()
//                     begin
//                         if TransferDate = 0D then
//                             Error('Transfer Date is required.');
//                     end;
//                 }

//                 field(RequestedBy; RequestedBy)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Requested By User';
//                     Editable = false;
//                 }

//                 field(SelectedFromLocation; SelectedFromLocation)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer-from Location';
//                     TableRelation = Location.Code;

//                     trigger OnValidate()
//                     begin
//                         if SelectedFromLocation <> '' then
//                             if SelectedFromLocation =
//                                SelectedToLocation
//                             then
//                                 Error(
//                                     'Source and destination locations must be different.');

//                         TempScanBuffer.Reset();
//                         TempScanBuffer.DeleteAll();

//                         CurrPage.ScanLines.Page.SetBuffer(
//                             TempScanBuffer);
//                         CurrPage.Update(false);
//                     end;
//                 }

//                 field(SelectedToLocation; SelectedToLocation)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Transfer-to Location';
//                     TableRelation = Location.Code;

//                     trigger OnValidate()
//                     begin
//                         if SelectedToLocation <> '' then
//                             if SelectedToLocation =
//                                SelectedFromLocation
//                             then
//                                 Error(
//                                     'Source and destination locations must be different.');
//                     end;
//                 }

//                 //     field(SelectedInTransitCode; SelectedInTransitCode)
//                 //     {
//                 //         ApplicationArea = All;
//                 //         Caption = 'In-Transit Location';
//                 //         TableRelation = Location.Code;

//                 //         trigger OnValidate()
//                 //         var
//                 //             LocationRec: Record Location;
//                 //         begin
//                 //             if SelectedInTransitCode = '' then
//                 //                 exit;

//                 //             if SelectedInTransitCode =
//                 //                SelectedFromLocation
//                 //             then
//                 //                 Error(
//                 //                     'In-transit location must differ from source.');

//                 //             if SelectedInTransitCode =
//                 //                SelectedToLocation
//                 //             then
//                 //                 Error(
//                 //                     'In-transit location must differ from destination.');

//                 //             LocationRec.Get(SelectedInTransitCode);

//                 //             if not LocationRec."Use As In-Transit" then
//                 //                 Error(
//                 //                     'Location %1 is not configured as an in-transit location.',
//                 //                     SelectedInTransitCode);
//                 //         end;
//                 //     }
//             }

//             group(ScanGroup)
//             {
//                 Caption = 'Barcode Scanner';

//                 field(ScannedBarcode; ScannedBarcode)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Scan Barcode / GTIN';
//                     ToolTip =
//                         'Scan a barcode and press Enter to add the item.';
//                     QuickEntry = true;

//                     trigger OnValidate()
//                     begin
//                         if ScannedBarcode <> '' then begin
//                             ProcessBarcode(ScannedBarcode);
//                             Clear(ScannedBarcode);
//                             CurrPage.ScanLines.Page.SetBuffer(
//                                 TempScanBuffer);
//                             CurrPage.Update(false);
//                         end;
//                     end;
//                 }

//                 field(DefaultQty; DefaultQty)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Quantity per Scan';
//                     DecimalPlaces = 0 : 5;

//                     trigger OnValidate()
//                     begin
//                         if DefaultQty <= 0 then
//                             Error(
//                                 'Quantity per scan must be greater than zero.');
//                     end;
//                 }
//             }

//             part(ScanLines; "Transfer Scan Lines")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(CreateTransferOrderAction)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Create Transfer Order';
//                 Image = CreateDocument;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 ToolTip =
//                     'Create and post a direct transfer from the scanned items.';

//                 trigger OnAction()
//                 begin
//                     CreateTransferOrder();
//                 end;
//             }

//             action(ClearScannedItems)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Clear Scanned Items';
//                 Image = ClearLog;

//                 trigger OnAction()
//                 begin
//                     if not Confirm(
//                         'Do you want to remove all scanned items?',
//                         false)
//                     then
//                         exit;

//                     TempScanBuffer.Reset();
//                     TempScanBuffer.DeleteAll();

//                     CurrPage.ScanLines.Page.SetBuffer(
//                         TempScanBuffer);

//                     CurrPage.Update(false);
//                 end;
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         TransferDate := WorkDate();
//         RequestedBy := CopyStr(UserId(), 1, MaxStrLen(RequestedBy));
//         DefaultQty := 1;

//         CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
//     end;

//     var
//         ScannedBarcode: Code[50];
//         SelectedFromLocation: Code[10];
//         SelectedToLocation: Code[10];
//         //  SelectedInTransitCode: Code[10];

//         TransferDate: Date;
//         RequestedBy: Code[50];
//         DefaultQty: Decimal;

//         TempScanBuffer: Record "Transfer Scan Buffer" temporary;

//     local procedure ProcessBarcode(BarcodeValue: Code[50])
//     var
//         Item: Record Item;
//         ItemReference: Record "Item Reference";
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         ItemNo: Code[20];
//         AvailableQty: Decimal;
//         RequestedQty: Decimal;
//         NextEntryNo: Integer;
//     begin
//         if SelectedFromLocation = '' then
//             Error('Select the source location before scanning.');

//         if SelectedToLocation = '' then
//             Error('Select the destination location before scanning.');

//         if SelectedFromLocation = SelectedToLocation then
//             Error(
//                 'Source and destination locations must be different.');

//         if TransferDate = 0D then
//             Error('Transfer Date is required.');

//         if DefaultQty <= 0 then
//             Error('Quantity per scan must be greater than zero.');

//         ItemNo := '';

//         // 1. Resolve barcode through Item Reference.
//         ItemReference.SetRange(
//             "Reference Type",
//             ItemReference."Reference Type"::"Bar Code");

//         ItemReference.SetRange("Reference No.", BarcodeValue);

//         if ItemReference.FindFirst() then
//             ItemNo := ItemReference."Item No.";

//         // 2. Fall back to the item's GTIN.
//         if ItemNo = '' then begin
//             if StrLen(BarcodeValue) <= MaxStrLen(Item.GTIN) then begin
//                 Item.SetRange(
//                     GTIN,
//                     CopyStr(
//                         BarcodeValue,
//                         1,
//                         MaxStrLen(Item.GTIN)));

//                 if Item.FindFirst() then
//                     ItemNo := Item."No.";
//             end;
//         end;

//         // 3. Fall back to direct Item No. scanning.
//         if ItemNo = '' then begin
//             if StrLen(BarcodeValue) <= MaxStrLen(Item."No.") then
//                 if Item.Get(
//                     CopyStr(
//                         BarcodeValue,
//                         1,
//                         MaxStrLen(Item."No.")))
//                 then
//                     ItemNo := Item."No.";
//         end;

//         if ItemNo = '' then
//             Error(
//                 'No item found for barcode/GTIN %1.',
//                 BarcodeValue);

//         Item.Get(ItemNo);

//         // 4. Only inventory items are eligible.
//         if Item.Type <> Item.Type::Inventory then
//             Error(
//                 'Item %1 must have Type = Inventory.',
//                 ItemNo);

//         if Item.Blocked then
//             Error('Item %1 is blocked.', ItemNo);

//         if Item."Base Unit of Measure" = '' then
//             Error(
//                 'Item %1 has no base unit of measure.',
//                 ItemNo);

//         // 5. Calculate on-hand stock at the source.
//         ItemLedgerEntry.Reset();
//         ItemLedgerEntry.SetRange("Item No.", ItemNo);
//         ItemLedgerEntry.SetRange(
//             "Location Code",
//             SelectedFromLocation);

//         ItemLedgerEntry.CalcSums("Remaining Quantity");

//         AvailableQty := ItemLedgerEntry."Remaining Quantity";

//         // 6. Accumulate repeated scans of the same item.
//         TempScanBuffer.Reset();
//         TempScanBuffer.SetRange("Item No.", ItemNo);

//         if TempScanBuffer.FindFirst() then begin
//             RequestedQty :=
//                 TempScanBuffer.Quantity + DefaultQty;

//             if RequestedQty > AvailableQty then
//                 Error(
//                     'Insufficient stock for item %1 at location %2. ' +
//                     'Available: %3; already requested: %4; ' +
//                     'additional scan: %5.',
//                     ItemNo,
//                     SelectedFromLocation,
//                     AvailableQty,
//                     TempScanBuffer.Quantity,
//                     DefaultQty);

//             TempScanBuffer.Quantity := RequestedQty;
//             TempScanBuffer.Barcode := BarcodeValue;
//             TempScanBuffer."Available Quantity" := AvailableQty;
//             TempScanBuffer.Modify();
//         end else begin
//             if DefaultQty > AvailableQty then
//                 Error(
//                     'Insufficient stock for item %1 at location %2. ' +
//                     'Available: %3; requested: %4.',
//                     ItemNo,
//                     SelectedFromLocation,
//                     AvailableQty,
//                     DefaultQty);

//             TempScanBuffer.Reset();

//             if TempScanBuffer.FindLast() then
//                 NextEntryNo := TempScanBuffer."Entry No." + 1
//             else
//                 NextEntryNo := 1;

//             TempScanBuffer.Init();
//             TempScanBuffer."Entry No." := NextEntryNo;
//             TempScanBuffer."Item No." := ItemNo;
//             TempScanBuffer.Description := Item.Description;
//             TempScanBuffer.Barcode := BarcodeValue;
//             TempScanBuffer.Quantity := DefaultQty;
//             TempScanBuffer."Unit of Measure Code" :=
//                 Item."Base Unit of Measure";
//             TempScanBuffer."Available Quantity" := AvailableQty;
//             TempScanBuffer.Insert();
//         end;
//     end;

//     local procedure CreateTransferOrder()
//     var
//         InventorySetup: Record "Inventory Setup";
//         TransferHeader: Record "Transfer Header";
//         TransferLine: Record "Transfer Line";
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         NoSeries: Codeunit "No. Series";
//         TransferOrderPost: Codeunit "TransferOrder-Post Transfer";
//         NewTransferNo: Code[20];
//         NextLineNo: Integer;
//         AvailableQty: Decimal;
//         ScannedLineCount: Integer;
//     begin
//         // 1. Validate mandatory header details.
//         if TransferDate = 0D then
//             Error('Transfer Date is required.');

//         if SelectedFromLocation = '' then
//             Error('Select the source location.');

//         if SelectedToLocation = '' then
//             Error('Select the destination location.');

//         if SelectedFromLocation = SelectedToLocation then
//             Error(
//                 'Source and destination locations must be different.');

//         TempScanBuffer.Reset();
//         if TempScanBuffer.IsEmpty() then
//             Error('Scan at least one item before creating a transfer.');

//         // 2. Revalidate source stock immediately before creation.
//         if TempScanBuffer.FindSet() then
//             repeat
//                 ItemLedgerEntry.Reset();
//                 ItemLedgerEntry.SetRange(
//                     "Item No.", TempScanBuffer."Item No.");
//                 ItemLedgerEntry.SetRange(
//                     "Location Code", SelectedFromLocation);
//                 ItemLedgerEntry.CalcSums("Remaining Quantity");

//                 AvailableQty := ItemLedgerEntry."Remaining Quantity";
//                 if TempScanBuffer.Quantity > AvailableQty then
//                     Error(
//                         'Stock has changed for item %1. Available: %2; requested: %3.',
//                         TempScanBuffer."Item No.",
//                         AvailableQty,
//                         TempScanBuffer.Quantity);
//             until TempScanBuffer.Next() = 0;

//         // 3. Get the standard Transfer Order number.
//         InventorySetup.Get();
//         InventorySetup.TestField("Transfer Order Nos.");
//         NewTransferNo := NoSeries.GetNextNo(
//             InventorySetup."Transfer Order Nos.", TransferDate);

//         // 4. Insert the header first so subsequent field validation
//         //    operates on an existing Transfer Header record.
//         TransferHeader.Init();
//         TransferHeader."No. Series" := InventorySetup."Transfer Order Nos.";
//         TransferHeader."No." := NewTransferNo;
//         TransferHeader."Requested By User ID" :=
//             CopyStr(UserId(), 1, MaxStrLen(TransferHeader."Requested By User ID"));
//         TransferHeader.Insert(true);

//         // 5. Set and validate the header fields.
//         TransferHeader.Validate("Transfer-from Code", SelectedFromLocation);
//         TransferHeader.Validate("Transfer-to Code", SelectedToLocation);

//         // Direct transfer avoids requiring an in-transit location.
//         TransferHeader.Validate("Direct Transfer", true);
//         TransferHeader.Validate("Posting Date", TransferDate);
//         TransferHeader.Validate("Shipment Date", TransferDate);
//         TransferHeader.Validate("Receipt Date", TransferDate);
//         TransferHeader.Modify(true);

//         // 6. Create standard Transfer Lines.
//         NextLineNo := 10000;
//         TempScanBuffer.Reset();
//         if TempScanBuffer.FindSet() then
//             repeat
//                 TransferLine.Init();
//                 TransferLine."Document No." := TransferHeader."No.";
//                 TransferLine."Line No." := NextLineNo;
//                 TransferLine.Validate("Item No.", TempScanBuffer."Item No.");
//                 TransferLine.Validate(
//                     "Unit of Measure Code", TempScanBuffer."Unit of Measure Code");
//                 TransferLine.Validate(Quantity, TempScanBuffer.Quantity);
//                 TransferLine.Insert(true);
//                 NextLineNo += 10000;
//             until TempScanBuffer.Next() = 0;

//         // 7. Post the direct transfer using standard Business Central posting.
//         // This updates inventory at both locations. No in-transit location is used.
//         ScannedLineCount := CountScannedLines();
//         TransferOrderPost.SetHideValidationDialog(true);
//         TransferOrderPost.RunWithCheck(TransferHeader);

//         // 8. Notify the user only after posting succeeds.
//         Message(
//             'Direct Transfer %1 has been posted successfully with %2 item line(s). Inventory was transferred from %3 to %4.',
//             NewTransferNo,
//             ScannedLineCount,
//             SelectedFromLocation,
//             SelectedToLocation);

//         // Clear the scanner buffer only after successful posting.
//         TempScanBuffer.Reset();
//         TempScanBuffer.DeleteAll();
//         Clear(ScannedBarcode);
//         CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
//         CurrPage.Update(false);
//     end;

//     local procedure CountScannedLines(): Integer
//     begin
//         TempScanBuffer.Reset();
//         exit(TempScanBuffer.Count());
//     end;
// }

page 50233 "Raw Material Transfer Scanner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Raw Material Transfer Scanner';

    layout
    {
        area(content)
        {
            group(TransferDetails)
            {
                Caption = 'Transfer Details';

                field(TransferDate; TransferDate)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Date';

                    trigger OnValidate()
                    begin
                        if TransferDate = 0D then
                            Error('Transfer Date is required.');
                    end;
                }

                field(RequestedBy; RequestedBy)
                {
                    ApplicationArea = All;
                    Caption = 'Requested By User';
                    Editable = false;
                }

                field(SelectedFromLocation; SelectedFromLocation)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer-from Location';
                    TableRelation = Location.Code;

                    trigger OnValidate()
                    begin
                        if SelectedFromLocation = '' then
                            Error('Transfer-from Location is mandatory.');

                        if (SelectedToLocation <> '') and
                           (SelectedFromLocation = SelectedToLocation)
                        then
                            Error(
                                'Source and destination locations must be different.');

                        // Clear scanned lines when the source location changes,
                        // so quantities from the previous source are not reused.
                        TempScanBuffer.Reset();
                        TempScanBuffer.DeleteAll();

                        CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
                        CurrPage.Update(false);
                    end;
                }

                field(SelectedToLocation; SelectedToLocation)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer-to Location';
                    TableRelation = Location.Code;

                    trigger OnValidate()
                    begin
                        if SelectedToLocation = '' then
                            Error('Transfer-to Location is mandatory.');

                        if (SelectedFromLocation <> '') and
                           (SelectedToLocation = SelectedFromLocation)
                        then
                            Error(
                                'Source and destination locations must be different.');
                    end;
                }

                //     field(SelectedInTransitCode; SelectedInTransitCode)
                //     {
                //         ApplicationArea = All;
                //         Caption = 'In-Transit Location';
                //         TableRelation = Location.Code;

                //         trigger OnValidate()
                //         var
                //             LocationRec: Record Location;
                //         begin
                //             if SelectedInTransitCode = '' then
                //                 exit;

                //             if SelectedInTransitCode =
                //                SelectedFromLocation
                //             then
                //                 Error(
                //                     'In-transit location must differ from source.');

                //             if SelectedInTransitCode =
                //                SelectedToLocation
                //             then
                //                 Error(
                //                     'In-transit location must differ from destination.');

                //             LocationRec.Get(SelectedInTransitCode);

                //             if not LocationRec."Use As In-Transit" then
                //                 Error(
                //                     'Location %1 is not configured as an in-transit location.',
                //                     SelectedInTransitCode);
                //         end;
                //     }
            }

            group(ScanGroup)
            {
                Caption = 'Barcode Scanner';

                field(ScannedBarcode; ScannedBarcode)
                {
                    ApplicationArea = All;
                    Caption = 'Scan Barcode / GTIN';
                    ToolTip =
                        'Scan a barcode and press Enter to add the item.';
                    QuickEntry = true;

                    trigger OnValidate()
                    begin
                        if ScannedBarcode <> '' then begin
                            ProcessBarcode(ScannedBarcode);
                            Clear(ScannedBarcode);
                            CurrPage.ScanLines.Page.SetBuffer(
                                TempScanBuffer);
                            CurrPage.Update(false);
                        end;
                    end;
                }

                field(DefaultQty; DefaultQty)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity per Scan';
                    DecimalPlaces = 0 : 5;

                    trigger OnValidate()
                    begin
                        if DefaultQty <= 0 then
                            Error(
                                'Quantity per scan must be greater than zero.');
                    end;
                }
            }

            part(ScanLines; "Transfer Scan Lines")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateTransferOrderAction)
            {
                ApplicationArea = All;
                Caption = 'Create Transfer Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip =
                    'Create and post a direct transfer from the scanned items.';

                trigger OnAction()
                begin
                    CreateTransferOrder();
                end;
            }

            action(ClearScannedItems)
            {
                ApplicationArea = All;
                Caption = 'Clear Scanned Items';
                Image = ClearLog;

                trigger OnAction()
                begin
                    if not Confirm(
                        'Do you want to remove all scanned items?',
                        false)
                    then
                        exit;

                    TempScanBuffer.Reset();
                    TempScanBuffer.DeleteAll();

                    CurrPage.ScanLines.Page.SetBuffer(
                        TempScanBuffer);

                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TransferDate := WorkDate();
        RequestedBy := CopyStr(UserId(), 1, MaxStrLen(RequestedBy));
        DefaultQty := 1;

        CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
    end;

    var
        ScannedBarcode: Code[50];
        SelectedFromLocation: Code[10];
        SelectedToLocation: Code[10];
        //  SelectedInTransitCode: Code[10];

        TransferDate: Date;
        RequestedBy: Code[50];
        DefaultQty: Decimal;

        TempScanBuffer: Record "Transfer Scan Buffer" temporary;

    local procedure ProcessBarcode(BarcodeValue: Code[50])
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemNo: Code[20];
        AvailableQty: Decimal;
        RequestedQty: Decimal;
        NextEntryNo: Integer;
    begin
        if SelectedFromLocation = '' then
            Error('Select the source location before scanning.');

        if SelectedToLocation = '' then
            Error('Select the destination location before scanning.');

        if SelectedFromLocation = SelectedToLocation then
            Error(
                'Source and destination locations must be different.');

        if TransferDate = 0D then
            Error('Transfer Date is required.');

        if DefaultQty <= 0 then
            Error('Quantity per scan must be greater than zero.');

        ItemNo := '';

        // 1. Resolve barcode through Item Reference.
        ItemReference.SetRange(
            "Reference Type",
            ItemReference."Reference Type"::"Bar Code");

        ItemReference.SetRange("Reference No.", BarcodeValue);

        if ItemReference.FindFirst() then
            ItemNo := ItemReference."Item No.";

        // 2. Fall back to the item's GTIN.
        if ItemNo = '' then begin
            if StrLen(BarcodeValue) <= MaxStrLen(Item.GTIN) then begin
                Item.SetRange(
                    GTIN,
                    CopyStr(
                        BarcodeValue,
                        1,
                        MaxStrLen(Item.GTIN)));

                if Item.FindFirst() then
                    ItemNo := Item."No.";
            end;
        end;

        // 3. Fall back to direct Item No. scanning.
        if ItemNo = '' then begin
            if StrLen(BarcodeValue) <= MaxStrLen(Item."No.") then
                if Item.Get(
                    CopyStr(
                        BarcodeValue,
                        1,
                        MaxStrLen(Item."No.")))
                then
                    ItemNo := Item."No.";
        end;

        if ItemNo = '' then
            Error(
                'No item found for barcode/GTIN %1.',
                BarcodeValue);

        Item.Get(ItemNo);

        // 4. Only inventory items are eligible.
        if Item.Type <> Item.Type::Inventory then
            Error(
                'Item %1 must have Type = Inventory.',
                ItemNo);

        if Item.Blocked then
            Error('Item %1 is blocked.', ItemNo);

        if Item."Base Unit of Measure" = '' then
            Error(
                'Item %1 has no base unit of measure.',
                ItemNo);

        // 5. Calculate on-hand stock at the source.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(
            "Location Code",
            SelectedFromLocation);

        ItemLedgerEntry.CalcSums("Remaining Quantity");

        AvailableQty := ItemLedgerEntry."Remaining Quantity";

        // 6. Accumulate repeated scans of the same item.
        TempScanBuffer.Reset();
        TempScanBuffer.SetRange("Item No.", ItemNo);

        if TempScanBuffer.FindFirst() then begin
            RequestedQty :=
                TempScanBuffer.Quantity + DefaultQty;

            if RequestedQty > AvailableQty then
                Error(
                    'Insufficient stock for item %1 at location %2. ' +
                    'Available: %3; already requested: %4; ' +
                    'additional scan: %5.',
                    ItemNo,
                    SelectedFromLocation,
                    AvailableQty,
                    TempScanBuffer.Quantity,
                    DefaultQty);

            TempScanBuffer.Quantity := RequestedQty;
            TempScanBuffer.Barcode := BarcodeValue;
            TempScanBuffer."Available Quantity" := AvailableQty;
            TempScanBuffer.Modify();
        end else begin
            if DefaultQty > AvailableQty then
                Error(
                    'Insufficient stock for item %1 at location %2. ' +
                    'Available: %3; requested: %4.',
                    ItemNo,
                    SelectedFromLocation,
                    AvailableQty,
                    DefaultQty);

            TempScanBuffer.Reset();

            if TempScanBuffer.FindLast() then
                NextEntryNo := TempScanBuffer."Entry No." + 1
            else
                NextEntryNo := 1;

            TempScanBuffer.Init();
            TempScanBuffer."Entry No." := NextEntryNo;
            TempScanBuffer."Item No." := ItemNo;
            TempScanBuffer.Description := Item.Description;
            TempScanBuffer.Barcode := BarcodeValue;
            TempScanBuffer.Quantity := DefaultQty;
            TempScanBuffer."Unit of Measure Code" :=
                Item."Base Unit of Measure";
            TempScanBuffer."Available Quantity" := AvailableQty;
            TempScanBuffer.Insert();
        end;
    end;

    local procedure CreateTransferOrder()
    var
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        NoSeries: Codeunit "No. Series";
        TransferOrderPost: Codeunit "TransferOrder-Post Transfer";
        NewTransferNo: Code[20];
        NextLineNo: Integer;
        AvailableQty: Decimal;
        ScannedLineCount: Integer;
    begin
        // 1. Validate mandatory header details.
        if TransferDate = 0D then
            Error('Transfer Date is required.');

        if SelectedFromLocation = '' then
            Error('Select the source location.');

        if SelectedToLocation = '' then
            Error('Select the destination location.');

        if SelectedFromLocation = SelectedToLocation then
            Error(
                'Source and destination locations must be different.');

        TempScanBuffer.Reset();
        if TempScanBuffer.IsEmpty() then
            Error('Scan at least one item before creating a transfer.');

        // 2. Revalidate source stock immediately before creation.
        if TempScanBuffer.FindSet() then
            repeat
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetRange(
                    "Item No.", TempScanBuffer."Item No.");
                ItemLedgerEntry.SetRange(
                    "Location Code", SelectedFromLocation);
                ItemLedgerEntry.CalcSums("Remaining Quantity");

                AvailableQty := ItemLedgerEntry."Remaining Quantity";
                if TempScanBuffer.Quantity > AvailableQty then
                    Error(
                        'Stock has changed for item %1. Available: %2; requested: %3.',
                        TempScanBuffer."Item No.",
                        AvailableQty,
                        TempScanBuffer.Quantity);
            until TempScanBuffer.Next() = 0;

        // 3. Get the standard Transfer Order number.
        InventorySetup.Get();
        InventorySetup.TestField("Transfer Order Nos.");
        NewTransferNo := NoSeries.GetNextNo(
            InventorySetup."Transfer Order Nos.", TransferDate);

        // 4. Insert the header first so subsequent field validation
        //    operates on an existing Transfer Header record.
        TransferHeader.Init();
        TransferHeader."No. Series" := InventorySetup."Transfer Order Nos.";
        TransferHeader."No." := NewTransferNo;
        TransferHeader."Requested By User ID" :=
            CopyStr(UserId(), 1, MaxStrLen(TransferHeader."Requested By User ID"));
        TransferHeader.Insert(true);

        // 5. Set and validate the header fields.
        TransferHeader.Validate("Transfer-from Code", SelectedFromLocation);
        TransferHeader.Validate("Transfer-to Code", SelectedToLocation);

        // Direct transfer avoids requiring an in-transit location.
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Validate("Posting Date", TransferDate);
        TransferHeader.Validate("Shipment Date", TransferDate);
        TransferHeader.Validate("Receipt Date", TransferDate);
        TransferHeader.Modify(true);

        // 6. Create standard Transfer Lines.
        NextLineNo := 10000;
        TempScanBuffer.Reset();
        if TempScanBuffer.FindSet() then
            repeat
                TransferLine.Init();
                TransferLine."Document No." := TransferHeader."No.";
                TransferLine."Line No." := NextLineNo;
                TransferLine.Validate("Item No.", TempScanBuffer."Item No.");
                TransferLine.Validate(
                    "Unit of Measure Code", TempScanBuffer."Unit of Measure Code");
                TransferLine.Validate(Quantity, TempScanBuffer.Quantity);
                TransferLine.Insert(true);
                NextLineNo += 10000;
            until TempScanBuffer.Next() = 0;

        // 7. Post the direct transfer using standard Business Central posting.
        // This updates inventory at both locations. No in-transit location is used.
        ScannedLineCount := CountScannedLines();
        TransferOrderPost.SetHideValidationDialog(true);
        TransferOrderPost.RunWithCheck(TransferHeader);

        // 8. Notify the user only after posting succeeds.
        Message(
            'Direct Transfer %1 has been posted successfully with %2 item line(s). Inventory was transferred from %3 to %4.',
            NewTransferNo,
            ScannedLineCount,
            SelectedFromLocation,
            SelectedToLocation);

        // Clear the scanner buffer only after successful posting.
        TempScanBuffer.Reset();
        TempScanBuffer.DeleteAll();
        Clear(ScannedBarcode);
        CurrPage.ScanLines.Page.SetBuffer(TempScanBuffer);
        CurrPage.Update(false);
    end;

    local procedure CountScannedLines(): Integer
    begin
        TempScanBuffer.Reset();
        exit(TempScanBuffer.Count());
    end;
}