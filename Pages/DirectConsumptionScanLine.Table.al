table 50240 "Direct Consumption Scan Line"
{
    Caption = 'Direct Consumption Scan Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item."No."; }
        field(3; Description; Text[100]) { Caption = 'Description'; }
        field(4; Barcode; Code[50]) { Caption = 'Barcode / GTIN'; }
        field(5; Quantity; Decimal) { Caption = 'Consumption Quantity'; DecimalPlaces = 0 : 5; }
        field(6; "Unit of Measure Code"; Code[10]) { Caption = 'Unit of Measure Code'; TableRelation = "Unit of Measure".Code; }
        field(7; "Available Quantity"; Decimal) { Caption = 'Available at Location'; DecimalPlaces = 0 : 5; }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}