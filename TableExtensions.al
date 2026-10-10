// --- 1. UNPOSTED DOCUMENT HEADERS ---
tableextension 50216 "SalesHeaderCustomRate" extends "Sales Header"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
            MinValue = 0;
        }
    }
}

tableextension 50217 "PurchHeaderCustomRate" extends "Purchase Header"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
            MinValue = 0;
        }
    }
}

// --- 2. JOURNALS ---
tableextension 50218 "GenJnlLineCustomRate" extends "Gen. Journal Line"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
            MinValue = 0;
        }
    }
}

tableextension 50219 "ItemJnlLineCustomRate" extends "Item Journal Line"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
            MinValue = 0;
        }
    }
}

// --- 3. POSTED DOCUMENT HEADERS ---
tableextension 50220 "SalesInvHeaderCustomRate" extends "Sales Invoice Header"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

tableextension 50221 "PurchInvHeaderCustomRate" extends "Purch. Inv. Header"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

// --- 4. TRANSACTION LEDGER ENTRIES ---
tableextension 50222 "GLEntryCustomRate" extends "G/L Entry"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

tableextension 50223 "CustLedgEntryCustomRate" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

tableextension 50224 "VendLedgEntryCustomRate" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

tableextension 50225 "BankLedgEntryCustomRate" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}

tableextension 50226 "ItemLedgEntryCustomRate" extends "Item Ledger Entry"
{
    fields
    {
        field(50216; "Custom Exch. Rate"; Decimal)
        {
            Caption = 'Additional Currency Exch. Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 12;
        }
    }
}