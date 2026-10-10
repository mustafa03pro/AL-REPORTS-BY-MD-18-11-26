codeunit 50253 "Indent to Purchase Order"
{
    // Caption = 'Indent to Purchase Order';

    procedure CreatePurchaseOrder(
        IndentNo: Code[20];
        var IndentLine: Record "Purchase Indent Line")
    var
        VendorRec: Record Vendor;
        IndentHeader: Record "Purchase Indent Header";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SelectedLine: Record "Purchase Indent Line";
        NextLineNo: Integer;
        QtyToOrder: Decimal;
    begin
        if IndentNo = '' then
            Error('The Purchase Indent must have a number before creating a Purchase Order.');

        if not IndentHeader.Get(IndentNo) then
            Error('Purchase Indent %1 was not found.', IndentNo);

        if IndentHeader.Status = IndentHeader.Status::Closed then
            Error('A closed indent cannot be converted.');

        if IndentLine.IsEmpty() then
            Error('Select at least one indent line.');

        if not (Page.RunModal(Page::"Vendor List", VendorRec) = Action::LookupOK) then
            exit;

        if VendorRec."No." = '' then
            Error('Select a vendor.');

        // Create the standard Business Central Purchase Order.
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", VendorRec."No.");
        PurchHeader.Modify(true);

        // Preserve the selected-line filter.
        SelectedLine.CopyFilters(IndentLine);

        if not SelectedLine.FindSet(true) then
            Error('No indent lines were selected.');

        repeat
            QtyToOrder := SelectedLine."Qty. to Order";

            if SelectedLine."Indent No." <> IndentNo then
                Error('A selected line belongs to another indent.');

            if SelectedLine."No." = '' then
                Error('Enter an item number on indent line %1.',
                    SelectedLine."Line No.");

            if QtyToOrder <= 0 then
                Error('Enter a positive Qty. to Order on line %1.',
                    SelectedLine."Line No.");

            if QtyToOrder >
               SelectedLine."Quantity Requested" -
               SelectedLine."Quantity Ordered"
            then
                Error(
                    'Qty. to Order exceeds the remaining quantity on line %1.',
                    SelectedLine."Line No.");

            NextLineNo += 10000;

            PurchLine.Init();
            PurchLine."Document Type" := PurchHeader."Document Type";
            PurchLine."Document No." := PurchHeader."No.";
            PurchLine."Line No." := NextLineNo;
            PurchLine.Insert(true);

            PurchLine.Validate(Type, PurchLine.Type::Item);
            PurchLine.Validate("No.", SelectedLine."No.");

            if SelectedLine."Location Code" <> '' then
                PurchLine.Validate(
                    "Location Code", SelectedLine."Location Code");

            if SelectedLine."Unit of Measure Code" <> '' then
                PurchLine.Validate(
                    "Unit of Measure Code",
                    SelectedLine."Unit of Measure Code");

            PurchLine.Validate(Quantity, QtyToOrder);

            if SelectedLine."Required Date" <> 0D then
                PurchLine.Validate(
                    "Expected Receipt Date",
                    SelectedLine."Required Date");

            PurchLine.Modify(true);

            // Update only the selected indent line.
            SelectedLine.Validate(
                "Quantity Ordered",
                SelectedLine."Quantity Ordered" + QtyToOrder);

            SelectedLine.Validate("Qty. to Order", 0);
            SelectedLine."Purchase Order No." := PurchHeader."No.";
            SelectedLine.Modify(true);

        until SelectedLine.Next() = 0;

        UpdateIndentStatus(IndentHeader);

        Message(
            'Purchase Order %1 was created successfully for vendor %2.',
            PurchHeader."No.",
            VendorRec."No.");

        Page.Run(Page::"Purchase Order", PurchHeader);
    end;

    local procedure UpdateIndentStatus(
        var IndentHeader: Record "Purchase Indent Header")
    var
        IndentLine: Record "Purchase Indent Line";
        HasOrdered: Boolean;
        HasRemaining: Boolean;
    begin
        IndentLine.SetRange("Indent No.", IndentHeader."No.");

        if IndentLine.FindSet() then
            repeat
                if IndentLine."Quantity Ordered" > 0 then
                    HasOrdered := true;

                if IndentLine."Quantity Ordered" <
                   IndentLine."Quantity Requested"
                then
                    HasRemaining := true;
            until IndentLine.Next() = 0;

        if not HasRemaining then
            IndentHeader.Status := IndentHeader.Status::"Fully Ordered"
        else
            if HasOrdered then
                IndentHeader.Status :=
                    IndentHeader.Status::"Partially Ordered"
            else
                IndentHeader.Status := IndentHeader.Status::Open;

        IndentHeader.Modify(true);
    end;
}