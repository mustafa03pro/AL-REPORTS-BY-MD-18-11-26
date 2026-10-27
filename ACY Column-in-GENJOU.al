// pageextension 50238 "GenJnl ACY Ext" extends "General Journal"
// {
//     layout
//     {
//         addlast(Control1)
//         {
//             field("ACY Amount"; ACYAmount)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Amount (ACY)';
//                 Editable = false;
//                 ToolTip = 'Line amount converted to the Additional Reporting Currency at the posting date rate.';
//             }
//             field("ACY Code"; ACYCode)
//             {
//                 ApplicationArea = All;
//                 Caption = 'ACY Code';
//                 Editable = false;
//             }
//         }
//     }

//     var
//         ACYAmount: Decimal;
//         ACYCode: Code[10];

//     trigger OnAfterGetRecord()
//     begin
//         CalcACY();
//     end;

//     trigger OnNewRecord(BelowxRec: Boolean)
//     begin
//         ACYAmount := 0;
//     end;

//     local procedure CalcACY()
//     var
//         GLSetup: Record "General Ledger Setup";
//         CurrExchRate: Record "Currency Exchange Rate";
//         PostingDate: Date;
//     begin
//         ACYAmount := 0;
//         GLSetup.Get();
//         ACYCode := GLSetup."Additional Reporting Currency";
//         if ACYCode = '' then
//             exit;

//         PostingDate := Rec."Posting Date";
//         if PostingDate = 0D then
//             PostingDate := WorkDate();

//         ACYAmount :=
//             CurrExchRate.ExchangeAmtLCYToFCY(
//                 PostingDate, ACYCode, Rec."Amount (LCY)",
//                 CurrExchRate.ExchangeRate(PostingDate, ACYCode));
//     end;
// }