// codeunit 50235 "CustomRatePostingMgt"
// {
//     SingleInstance = true;

//     // =========================================================================
//     // 1. SALES: Set Currency Factor on Document & Copy to Posted Invoice
//     // =========================================================================
//     [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Custom Exch. Rate', false, false)]
//     local procedure OnAfterValidateSalesCustomRate(var Rec: Record "Sales Header")
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec."Custom Exch. Rate" > 0 then
//             Rec.Validate("Currency Factor", 1 / Rec."Custom Exch. Rate");
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostLines', '', false, false)]
//     local procedure OnBeforePostSalesLines(SalesHeader: Record "Sales Header")
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         // Cache the custom rate to apply to downstream ledger entries
//         GlobalCustomExchRate := SalesHeader."Custom Exch. Rate";
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertSalesInvoiceHeader(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
//     var
//         SalesHeader: Record "Sales Header";
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Order No.") then
//             Rec."Custom Exch. Rate" := SalesHeader."Custom Exch. Rate"
//         else if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Order No.") then
//             Rec."Custom Exch. Rate" := SalesHeader."Custom Exch. Rate";

//         if Rec."Custom Exch. Rate" > 0 then
//             Rec.Modify();
//     end;

//     // =========================================================================
//     // 2. PURCHASE: Set Currency Factor on Document & Copy to Posted Invoice
//     // =========================================================================
//     [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Custom Exch. Rate', false, false)]
//     local procedure OnAfterValidatePurchCustomRate(var Rec: Record "Purchase Header")
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec."Custom Exch. Rate" > 0 then
//             Rec.Validate("Currency Factor", 1 / Rec."Custom Exch. Rate");
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostLines', '', false, false)]
//     local procedure OnBeforePostPurchLines(PurchHeader: Record "Purchase Header")
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         GlobalCustomExchRate := PurchHeader."Custom Exch. Rate";
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertPurchInvoiceHeader(var Rec: Record "Purch. Inv. Header"; RunTrigger: Boolean)
//     var
//         PurchHeader: Record "Purchase Header";
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if PurchHeader.Get(PurchHeader."Document Type"::Invoice, Rec."Order No.") then
//             Rec."Custom Exch. Rate" := PurchHeader."Custom Exch. Rate"
//         else if PurchHeader.Get(PurchHeader."Document Type"::Order, Rec."Order No.") then
//             Rec."Custom Exch. Rate" := PurchHeader."Custom Exch. Rate";

//         if Rec."Custom Exch. Rate" > 0 then
//             Rec.Modify();
//     end;

//     // =========================================================================
//     // 3. GENERAL JOURNAL: Override Factor & Adjust LCY
//     // =========================================================================
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
//     local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if (GenJournalLine."Custom Exch. Rate" > 0) and (GenJournalLine."Currency Code" <> '') then begin
//             GenJournalLine."Currency Factor" := 1 / GenJournalLine."Custom Exch. Rate";
//             GenJournalLine."Amount (LCY)" := Round(GenJournalLine.Amount * GenJournalLine."Custom Exch. Rate");
//             GenJournalLine."Balance (LCY)" := Round(GenJournalLine."Balance (LCY)" * GenJournalLine."Custom Exch. Rate");
//             GlobalCustomExchRate := GenJournalLine."Custom Exch. Rate";
//         end;
//     end;

//     // =========================================================================
//     // 4. LEDGER ENTRIES: Store Custom Rate on Transaction Inserts
//     // =========================================================================
//     [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertGLEntry(var Rec: Record "G/L Entry"; RunTrigger: Boolean)
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if GlobalCustomExchRate > 0 then begin
//             Rec."Custom Exch. Rate" := GlobalCustomExchRate;
//             Rec.Modify();
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertCustLedgerEntry(var Rec: Record "Cust. Ledger Entry"; RunTrigger: Boolean)
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if GlobalCustomExchRate > 0 then begin
//             Rec."Custom Exch. Rate" := GlobalCustomExchRate;
//             Rec.Modify();
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertVendLedgerEntry(var Rec: Record "Vendor Ledger Entry"; RunTrigger: Boolean)
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if GlobalCustomExchRate > 0 then begin
//             Rec."Custom Exch. Rate" := GlobalCustomExchRate;
//             Rec.Modify();
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertBankAccLedgEntry(var Rec: Record "Bank Account Ledger Entry"; RunTrigger: Boolean)
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if GlobalCustomExchRate > 0 then begin
//             Rec."Custom Exch. Rate" := GlobalCustomExchRate;
//             Rec.Modify();
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertItemLedgEntry(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
//     begin
//         if CompanyName() <> 'CIFEAC_BACKUP_21_08_2026' then
//             exit;

//         if Rec.IsTemporary() then
//             exit;

//         if GlobalCustomExchRate > 0 then begin
//             Rec."Custom Exch. Rate" := GlobalCustomExchRate;
//             Rec.Modify();
//         end;
//     end;

//     var
//         GlobalCustomExchRate: Decimal;
// }