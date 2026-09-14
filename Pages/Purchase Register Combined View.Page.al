page 50201 "Purchase Register Combined Vi"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    SourceTable = "Purchase Register Combined";
    SourceTableTemporary = true;

    Caption = 'Purchase Register Combined View';

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                field(StartDate; StartDate)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }

                field(EndDate; EndDate)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
            }

            repeater(Group)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }

                field(VendorCode; Rec.VendorCode)
                {
                    ApplicationArea = All;
                }

                field(VendorName; Rec.VendorName)
                {
                    ApplicationArea = All;
                }

                field(InvoiceNo; Rec.InvoiceNo)
                {
                    ApplicationArea = All;
                }

                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = All;
                }

                field(ItemDescription; Rec.ItemDescription)
                {
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }

                field(UnitCost; Rec.UnitCost)
                {
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }

                field(VATAmount; Rec.VATAmount)
                {
                    ApplicationArea = All;
                }

                field(TotalAmount; Rec.TotalAmount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshData)
            {
                Caption = 'Refresh';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                begin
                    ApplyFilters();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    var
        StartDate: Date;
        EndDate: Date;

    local procedure PopulatePurchaseRegister(var TempRec: Record "Purchase Register Combined" temporary)

    // We'll add the code here

    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        Counter: Integer;
    begin
        TempRec.Reset();
        TempRec.DeleteAll();

        Counter := 0;

        // Apply Posting Date filter
        if (StartDate <> 0D) and (EndDate <> 0D) then
            PurchInvHeader.SetRange("Posting Date", StartDate, EndDate)
        else
            PurchInvHeader.Reset();

        if PurchInvHeader.FindSet() then
            repeat
                PurchInvLine.Reset();
                PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");

                if PurchInvLine.FindSet() then
                    repeat
                        Counter += 1;

                        TempRec.Init();

                        TempRec.EntryNo := Counter;
                        TempRec.Date := PurchInvHeader."Posting Date";
                        TempRec.VendorCode := PurchInvHeader."Buy-from Vendor No.";
                        TempRec.VendorName := PurchInvHeader."Buy-from Vendor Name";
                        TempRec.InvoiceNo := PurchInvHeader."No.";
                        TempRec.ItemNo := PurchInvLine."No.";
                        TempRec.ItemDescription := PurchInvLine.Description;
                        TempRec.Quantity := PurchInvLine.Quantity;
                        TempRec.UnitCost := PurchInvLine."Direct Unit Cost";
                        TempRec.Amount := PurchInvLine.Amount;
                        TempRec.VATAmount := Round(PurchInvLine.Amount * PurchInvLine."VAT %" / 100, 0.01);
                        TempRec.TotalAmount := TempRec.Amount + TempRec.VATAmount;

                        TempRec.Insert();
                    until PurchInvLine.Next() = 0;

            until PurchInvHeader.Next() = 0;
    end;

    local procedure ApplyFilters()
    begin
        PopulatePurchaseRegister(Rec);
        CurrPage.Update(false);
    end;

}