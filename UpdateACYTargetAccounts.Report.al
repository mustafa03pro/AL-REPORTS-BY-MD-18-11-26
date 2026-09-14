// report 50209 "Update ACY Target Accounts"
// {
//     UsageCategory = Tasks;
//     ApplicationArea = All;
//     ProcessingOnly = true;
//     Permissions = TableData "G/L Entry" = rimd;

//     trigger OnPreReport()
//     var
//         GLEntry: Record "G/L Entry";
//         TargetRate: Decimal;
//         Counter: Integer;
//     begin
//         // Hard safety check: Lock execution ONLY to CIFEAC_BACKUP_21_08_2026
//         if CompanyName <> 'CIFEAC_BACKUP_21_08_2026' then
//             Error('Execution blocked: This report can only be run in company CIFEAC_BACKUP_21_08_2026.');

//         TargetRate := 612.067;
//         Counter := 0;

//         // Filter G/L Entries specifically for the target accounts
//         GLEntry.SetFilter("G/L Account No.", '10111|10112|10113');

//         if GLEntry.FindSet(true) then begin
//             repeat
//                 // Recalculate historical ACY directly using LCY base balance
//                 GLEntry."Additional-Currency Amount" := GLEntry.Amount / TargetRate;
//                 GLEntry.Modify();
//                 Counter += 1;
//             until GLEntry.Next() = 0;

//             Message('Successfully updated %1 G/L entries in company %2.', Counter, CompanyName);
//         end else
//             Message('No G/L entries found for accounts 10111, 10112, or 10113.');
//     end;
// }

// report 50209 "Update ACY Target Accounts"
// {
//     UsageCategory = Tasks;
//     ApplicationArea = All;
//     ProcessingOnly = true;
//     UseRequestPage = false;
//     Permissions = TableData "G/L Entry" = rimd;

//     trigger OnPreReport()
//     var
//         GLEntry: Record "G/L Entry";
//         TargetRate: Decimal;
//         Counter: Integer;
//         StartDate: Date;
//         EndDate: Date;
//     begin
//         // Hard safety check: Lock execution ONLY to company CIFEAC_BACKUP_21_08_2026
//         if CompanyName <> 'CIFEAC_BACKUP_21_08_2026' then
//             Error('Execution blocked: This report can only be run in company CIFEAC_BACKUP_21_08_2026.');

//         TargetRate := 610.67;
//         Counter := 0;
//         StartDate := 20250101D; // 01/01/2025
//         EndDate := 20251231D;   // 31/12/2025

//         // Filter G/L Entries by Posting Date range (01/01/2025 .. 31/12/2025)
//         GLEntry.SetRange("Posting Date", StartDate, EndDate);

//         if GLEntry.FindSet(true) then begin
//             repeat
//                 // Recalculate historical ACY directly using LCY base amount
//                 GLEntry."Additional-Currency Amount" := GLEntry.Amount / TargetRate;
//                 GLEntry.Modify();
//                 Counter += 1;
//             until GLEntry.Next() = 0;

//             Message('Successfully updated %1 G/L entries between %2 and %3 in company %4.', Counter, StartDate, EndDate, CompanyName);
//         end else
//             Message('No G/L entries found within the date range 01/01/2025 to 31/12/2025.');
//     end;
// }


// report 50209 "Update ACY Target Accounts"
// {
//     UsageCategory = Tasks;
//     ApplicationArea = All;
//     ProcessingOnly = true;
//     UseRequestPage = false;
//     Permissions = TableData "G/L Entry" = rimd;

//     trigger OnPreReport()
//     var
//         GLEntry: Record "G/L Entry";
//         RatesDict: Dictionary of [Code[20], Decimal];
//         Counter: Integer;
//         StartDate: Date;
//         EndDate: Date;
//         TargetRate: Decimal;
//     begin
//         // Lock execution ONLY to company CIFEAC_BACKUP_21_08_2026
//         if CompanyName <> 'CIFEAC_BACKUP_21_08_2026' then
//             Error('Execution blocked: This report can only be run in company CIFEAC_BACKUP_21_08_2026.');

//         // Load exchange rates only for valid G/L accounts
//         LoadAccountExchangeRates(RatesDict);

//         // Date Range for 2026
//         StartDate := 20260101D;
//         EndDate := 20260731D;
//         Counter := 0;

//         // Filter G/L Entries by Posting Date
//         GLEntry.SetRange("Posting Date", StartDate, EndDate);

//         if GLEntry.FindSet(true) then begin
//             repeat
//                 // Only update entries whose G/L Account has an explicit exchange rate defined
//                 if RatesDict.Get(GLEntry."G/L Account No.", TargetRate) then
//                     if TargetRate <> 0 then begin
//                         GLEntry."Additional-Currency Amount" := GLEntry.Amount / TargetRate;
//                         GLEntry.Modify();
//                         Counter += 1;
//                     end;
//             until GLEntry.Next() = 0;

//             Message('Successfully updated %1 G/L entries between %2 and %3 in company %4.', Counter, StartDate, EndDate, CompanyName);
//         end else
//             Message('No G/L entries found within the date range 01/01/2026 to 31/07/2026.');
//     end;

//     local procedure LoadAccountExchangeRates(var RatesDict: Dictionary of [Code[20], Decimal])
//     begin
//         Clear(RatesDict);
//         RatesDict.Add('10111', 612.067113);
//         RatesDict.Add('10112', 612.065162);
//         RatesDict.Add('10113', 612.065162);
//         RatesDict.Add('10135', 603.796193);
//         RatesDict.Add('10203', 600.189224);
//         RatesDict.Add('10204', 626.410714);
//         RatesDict.Add('10205', 626.410714);
//         RatesDict.Add('10206', 629.548379);
//         RatesDict.Add('10207', 629.548212);
//         RatesDict.Add('10208', 629.548212);
//         RatesDict.Add('10252', 582.760774);
//         RatesDict.Add('10253', 582.760774);
//         RatesDict.Add('10254', 597.566984);
//         RatesDict.Add('10255', 599.300547);
//         RatesDict.Add('10281', 583.735637);
//         RatesDict.Add('10282', 546.243254);
//         RatesDict.Add('10283', 600.003959);
//         RatesDict.Add('10302', 585.684801);
//         RatesDict.Add('10307', 587.448522);
//         RatesDict.Add('10314', 600.0);
//         RatesDict.Add('10401', 591.449856);
//         RatesDict.Add('10402', 600.70254);
//         RatesDict.Add('10403', 581.969974);
//         RatesDict.Add('10404', 600.70254);
//         RatesDict.Add('20004', 603.0);
//         RatesDict.Add('20007', 615.373395);
//         RatesDict.Add('20008', 616.213707);
//         RatesDict.Add('20011', 615.373395);
//         RatesDict.Add('20012', 616.213707);
//         RatesDict.Add('20015', 615.373395);
//         RatesDict.Add('20016', 616.213707);
//         RatesDict.Add('20019', 615.373395);
//         RatesDict.Add('20020', 616.213707);
//         RatesDict.Add('20023', 615.373395);
//         RatesDict.Add('20024', 616.213707);
//         RatesDict.Add('20027', 615.373395);
//         RatesDict.Add('20028', 616.213707);
//         RatesDict.Add('20031', 615.373395);
//         RatesDict.Add('20032', 616.213707);
//         RatesDict.Add('20035', 615.373395);
//         RatesDict.Add('20036', 616.213707);
//         RatesDict.Add('20039', 615.373395);
//         RatesDict.Add('20040', 616.213707);
//         RatesDict.Add('20043', 615.373395);
//         RatesDict.Add('20044', 616.213707);
//         RatesDict.Add('20047', 615.373395);
//         RatesDict.Add('20048', 616.213707);
//         RatesDict.Add('20051', 615.373395);
//         RatesDict.Add('20052', 616.213707);
//         RatesDict.Add('20055', 615.373395);
//         RatesDict.Add('20056', 616.213707);
//         RatesDict.Add('20059', 615.373395);
//         RatesDict.Add('20060', 616.213707);
//         RatesDict.Add('20063', 615.373395);
//         RatesDict.Add('20064', 616.213707);
//         RatesDict.Add('20067', 615.373395);
//         RatesDict.Add('20068', 616.213707);
//         RatesDict.Add('20071', 615.373395);
//         RatesDict.Add('20072', 616.213707);
//         RatesDict.Add('20075', 615.373395);
//         RatesDict.Add('20076', 616.213707);
//         RatesDict.Add('20079', 615.373395);
//         RatesDict.Add('20080', 616.213707);
//         RatesDict.Add('20083', 615.373395);
//         RatesDict.Add('20084', 616.213707);
//         RatesDict.Add('20087', 615.373395);
//         RatesDict.Add('20088', 616.213707);
//         RatesDict.Add('20091', 615.373395);
//         RatesDict.Add('20092', 616.213707);
//         RatesDict.Add('20095', 615.373395);
//         RatesDict.Add('20096', 616.213707);
//         RatesDict.Add('20101', 603.0);
//         RatesDict.Add('20102', 603.0);
//         RatesDict.Add('20103', 603.0);
//         RatesDict.Add('20104', 603.0);
//         RatesDict.Add('20105', 603.0);
//         RatesDict.Add('20106', 603.0);
//         RatesDict.Add('20107', 603.0);
//         RatesDict.Add('20108', 603.0);
//         RatesDict.Add('20111', 603.0);
//         RatesDict.Add('20112', 603.0);
//         RatesDict.Add('20202', 600.0);
//         RatesDict.Add('20203', 600.0);
//         RatesDict.Add('20205', 600.0);
//         RatesDict.Add('20301', 610.142278);
//         RatesDict.Add('20302', 610.142278);
//         RatesDict.Add('20303', 610.142278);
//         RatesDict.Add('20304', 610.142278);
//         RatesDict.Add('20305', 610.142278);
//         RatesDict.Add('20306', 610.142278);
//         RatesDict.Add('20307', 610.142278);
//         RatesDict.Add('20308', 610.142278);
//         RatesDict.Add('20309', 610.142278);
//         RatesDict.Add('20310', 610.142278);
//         RatesDict.Add('20311', 610.142278);
//         RatesDict.Add('20312', 610.142278);
//         RatesDict.Add('20313', 610.142278);
//         RatesDict.Add('20314', 610.142278);
//         RatesDict.Add('20315', 610.142278);
//         RatesDict.Add('20316', 610.142278);
//         RatesDict.Add('20317', 610.142278);
//         RatesDict.Add('20318', 610.142278);
//         RatesDict.Add('20319', 610.142278);
//         RatesDict.Add('20320', 610.142278);
//         RatesDict.Add('20321', 610.142278);
//         RatesDict.Add('20322', 610.142278);
//         RatesDict.Add('20323', 610.142278);
//         RatesDict.Add('20324', 610.142278);
//         RatesDict.Add('20325', 610.142278);
//         RatesDict.Add('20326', 610.142278);
//         RatesDict.Add('20327', 610.142278);
//         RatesDict.Add('20328', 610.142278);
//         RatesDict.Add('20329', 610.142278);
//         RatesDict.Add('20330', 610.142278);
//         RatesDict.Add('20331', 610.142278);
//         RatesDict.Add('20332', 610.142278);
//         RatesDict.Add('20333', 610.142278);
//         RatesDict.Add('20334', 610.142278);
//         RatesDict.Add('20335', 610.142278);
//         RatesDict.Add('20336', 610.142278);
//         RatesDict.Add('20337', 610.142278);
//         RatesDict.Add('20338', 610.142278);
//         RatesDict.Add('20339', 610.142278);
//         RatesDict.Add('20340', 610.142278);
//         RatesDict.Add('20341', 610.142278);
//         RatesDict.Add('20342', 610.142278);
//         RatesDict.Add('20343', 610.142278);
//         RatesDict.Add('20344', 610.142278);
//         RatesDict.Add('20345', 610.142278);
//         RatesDict.Add('20346', 610.142278);
//         RatesDict.Add('20347', 610.142278);
//         RatesDict.Add('20348', 610.142278);
//         RatesDict.Add('20349', 610.142278);
//         RatesDict.Add('20350', 610.142278);
//         RatesDict.Add('20351', 610.142278);
//         RatesDict.Add('20352', 610.142278);
//         RatesDict.Add('20353', 610.142278);
//         RatesDict.Add('20354', 610.142278);
//         RatesDict.Add('20355', 610.142278);
//         RatesDict.Add('20356', 610.142278);
//         RatesDict.Add('20357', 610.142278);
//         RatesDict.Add('20358', 610.142278);
//         RatesDict.Add('20359', 610.142278);
//         RatesDict.Add('20360', 610.142278);
//         RatesDict.Add('20361', 610.142278);
//         RatesDict.Add('20362', 610.142278);
//         RatesDict.Add('20363', 610.142278);
//         RatesDict.Add('20364', 610.142278);
//         RatesDict.Add('20365', 610.142278);
//         RatesDict.Add('20366', 610.142278);
//         RatesDict.Add('20367', 610.142278);
//         RatesDict.Add('20368', 610.142278);
//         RatesDict.Add('20369', 610.142278);
//         RatesDict.Add('20370', 610.142278);
//         RatesDict.Add('20371', 610.142278);
//         RatesDict.Add('20372', 610.142278);
//         RatesDict.Add('20373', 610.142278);
//         RatesDict.Add('20374', 610.142278);
//         RatesDict.Add('20375', 610.142278);
//         RatesDict.Add('20376', 610.142278);
//         RatesDict.Add('20401', 579.337237);
//         RatesDict.Add('20402', 579.337237);
//         RatesDict.Add('20403', 579.337237);
//         RatesDict.Add('20404', 579.337237);
//         RatesDict.Add('20405', 579.337237);
//         RatesDict.Add('20406', 579.337237);
//         RatesDict.Add('20407', 579.337237);
//         RatesDict.Add('20408', 579.337237);
//         RatesDict.Add('20409', 579.337237);
//         RatesDict.Add('20410', 579.337237);
//         RatesDict.Add('20411', 579.337237);
//         RatesDict.Add('20412', 579.337237);
//         RatesDict.Add('20413', 579.337237);
//         RatesDict.Add('20501', 627.042792);
//         RatesDict.Add('20502', 613.882895);
//         RatesDict.Add('20503', 600.0);
//         RatesDict.Add('20504', 600.0);
//         RatesDict.Add('20505', 600.0);
//         RatesDict.Add('20506', 600.0);
//         RatesDict.Add('20601', 584.487553);
//         RatesDict.Add('20602', 594.398018);
//         RatesDict.Add('20603', 599.999818);
//         RatesDict.Add('20604', 599.999818);
//         RatesDict.Add('20605', 599.999818);
//         RatesDict.Add('20606', 599.999818);
//         RatesDict.Add('20607', 599.999818);
//         RatesDict.Add('20608', 599.999818);
//         RatesDict.Add('20609', 599.999818);
//         RatesDict.Add('20610', 599.999818);
//         RatesDict.Add('20701', 590.280145);
//         RatesDict.Add('20702', 600.0);
//         RatesDict.Add('20703', 581.968485);
//         RatesDict.Add('20704', 600.0);
//         RatesDict.Add('30101', 600.0);
//         RatesDict.Add('30102', 600.0);
//         RatesDict.Add('30103', 600.0);
//         RatesDict.Add('30104', 600.0);
//         RatesDict.Add('30105', 600.0);
//         RatesDict.Add('30106', 600.0);
//         RatesDict.Add('30107', 600.0);
//         RatesDict.Add('30108', 600.0);
//         RatesDict.Add('40000', 600.0);
//         RatesDict.Add('40001', 600.0);
//         RatesDict.Add('40002', 600.0);
//         RatesDict.Add('40003', 600.0);
//         RatesDict.Add('40004', 600.0);
//         RatesDict.Add('40005', 600.0);
//         RatesDict.Add('40006', 600.0);
//         RatesDict.Add('40007', 600.0);
//         RatesDict.Add('40008', 600.0);
//         RatesDict.Add('40009', 600.0);
//         RatesDict.Add('40010', 600.0);
//         RatesDict.Add('40011', 600.0);
//         RatesDict.Add('40012', 600.0);
//         RatesDict.Add('40013', 600.0);
//         RatesDict.Add('40014', 600.0);
//         RatesDict.Add('40015', 600.0);
//         RatesDict.Add('40016', 600.0);
//         RatesDict.Add('40017', 600.0);
//         RatesDict.Add('40018', 600.0);
//         RatesDict.Add('40149', 600.0);
//         RatesDict.Add('40150', 600.0);
//         RatesDict.Add('40151', 600.0);
//         RatesDict.Add('40152', 600.0);
//         RatesDict.Add('40153', 600.0);
//         RatesDict.Add('40154', 600.0);
//         RatesDict.Add('40155', 600.0);
//         RatesDict.Add('40156', 600.0);
//         RatesDict.Add('40157', 600.0);
//         RatesDict.Add('40158', 600.0);
//         RatesDict.Add('40159', 600.0);
//         RatesDict.Add('40160', 600.0);
//         RatesDict.Add('40249', 600.0);
//         RatesDict.Add('40250', 600.0);
//         RatesDict.Add('40251', 600.0);
//         RatesDict.Add('40252', 600.0);
//         RatesDict.Add('40253', 600.0);
//         RatesDict.Add('40254', 600.0);
//         RatesDict.Add('40255', 600.0);
//         RatesDict.Add('40256', 600.0);
//         RatesDict.Add('40257', 600.0);
//         RatesDict.Add('40258', 600.0);
//         RatesDict.Add('40299', 600.0);
//         RatesDict.Add('40300', 600.0);
//         RatesDict.Add('40301', 600.0);
//         RatesDict.Add('40302', 600.0);
//         RatesDict.Add('40303', 600.0);
//         RatesDict.Add('40304', 600.0);
//         RatesDict.Add('40305', 600.0);
//         RatesDict.Add('40306', 600.0);
//         RatesDict.Add('40307', 600.0);
//         RatesDict.Add('40308', 600.0);
//         RatesDict.Add('40309', 600.0);
//         RatesDict.Add('40310', 600.0);
//         RatesDict.Add('40311', 600.0);
//         RatesDict.Add('40312', 600.0);
//         RatesDict.Add('40313', 600.0);
//         RatesDict.Add('40314', 600.0);
//         RatesDict.Add('40351', 600.0);
//         RatesDict.Add('40352', 600.0);
//         RatesDict.Add('40449', 600.0);
//         RatesDict.Add('40450', 600.0);
//         RatesDict.Add('40451', 600.0);
//         RatesDict.Add('40452', 600.0);
//         RatesDict.Add('40453', 600.0);
//         RatesDict.Add('40454', 600.0);
//         RatesDict.Add('40455', 600.0);
//         RatesDict.Add('40456', 600.0);
//         RatesDict.Add('40457', 600.0);
//         RatesDict.Add('40458', 600.0);
//         RatesDict.Add('40459', 600.0);
//         RatesDict.Add('40460', 600.0);
//         RatesDict.Add('40461', 600.0);
//         RatesDict.Add('40462', 600.0);
//         RatesDict.Add('40463', 600.0);
//         RatesDict.Add('40464', 600.0);
//         RatesDict.Add('40465', 600.0);
//         RatesDict.Add('40466', 600.0);
//         RatesDict.Add('40467', 600.0);
//         RatesDict.Add('40468', 600.0);
//         RatesDict.Add('40469', 600.0);
//         RatesDict.Add('40470', 600.0);
//         RatesDict.Add('40471', 600.0);
//         RatesDict.Add('40549', 600.0);
//         RatesDict.Add('40550', 600.0);
//         RatesDict.Add('40551', 600.0);
//         RatesDict.Add('40552', 600.0);
//         RatesDict.Add('40553', 600.0);
//         RatesDict.Add('40554', 600.0);
//         RatesDict.Add('40555', 600.0);
//         RatesDict.Add('40556', 600.0);
//         RatesDict.Add('40557', 600.0);
//         RatesDict.Add('40558', 600.0);
//         RatesDict.Add('40559', 600.0);
//         RatesDict.Add('40560', 600.0);
//         RatesDict.Add('40561', 600.0);
//         RatesDict.Add('40562', 600.0);
//         RatesDict.Add('40563', 600.0);
//         RatesDict.Add('40564', 600.0);
//         RatesDict.Add('40565', 600.0);
//         RatesDict.Add('40566', 600.0);
//         RatesDict.Add('40567', 600.0);
//         RatesDict.Add('40568', 600.0);
//         RatesDict.Add('40569', 600.0);
//         RatesDict.Add('40570', 600.0);
//         RatesDict.Add('40571', 600.0);
//         RatesDict.Add('40572', 600.0);
//         RatesDict.Add('40573', 600.0);
//         RatesDict.Add('40574', 600.0);
//         RatesDict.Add('40575', 600.0);
//         RatesDict.Add('40576', 600.0);
//         RatesDict.Add('40577', 600.0);
//         RatesDict.Add('40578', 600.0);
//         RatesDict.Add('40579', 600.0);
//         RatesDict.Add('40580', 600.0);
//         RatesDict.Add('40581', 600.0);
//         RatesDict.Add('40582', 600.0);
//         RatesDict.Add('40583', 600.0);
//         RatesDict.Add('40584', 600.0);
//         RatesDict.Add('40585', 600.0);
//         RatesDict.Add('40586', 600.0);
//         RatesDict.Add('40587', 600.0);
//         RatesDict.Add('40588', 600.0);
//         RatesDict.Add('40589', 600.0);
//         RatesDict.Add('40590', 600.0);
//         RatesDict.Add('40591', 600.0);
//         RatesDict.Add('40592', 600.0);
//         RatesDict.Add('40593', 600.0);
//         RatesDict.Add('40594', 600.0);
//         RatesDict.Add('40595', 600.0);
//         RatesDict.Add('40596', 600.0);
//         RatesDict.Add('40597', 600.0);
//         RatesDict.Add('40598', 600.0);
//         RatesDict.Add('40599', 600.0);
//         RatesDict.Add('40849', 600.0);
//         RatesDict.Add('40850', 600.0);
//         RatesDict.Add('40851', 600.0);
//         RatesDict.Add('40852', 600.0);
//         RatesDict.Add('40853', 600.0);
//         RatesDict.Add('40854', 42.54588);
//         RatesDict.Add('40855', 600.0);
//         RatesDict.Add('40856', 600.0);
//         RatesDict.Add('40857', 600.0);
//         RatesDict.Add('40858', 600.0);
//         RatesDict.Add('40859', 600.0);
//         RatesDict.Add('40860', 600.0);
//         RatesDict.Add('40861', 600.0);
//         RatesDict.Add('40862', 600.0);
//         RatesDict.Add('40863', 600.0);
//         RatesDict.Add('40919', 600.0);
//         RatesDict.Add('40920', 600.0);
//         RatesDict.Add('40921', 600.0);
//         RatesDict.Add('40922', 600.0);
//         RatesDict.Add('40923', 600.0);
//         RatesDict.Add('40924', 600.0);
//         RatesDict.Add('40925', 600.0);
//         RatesDict.Add('40926', 600.0);
//         RatesDict.Add('40927', 600.0);
//         RatesDict.Add('40928', 600.0);
//         RatesDict.Add('40929', 600.0);
//         RatesDict.Add('40930', 600.0);
//         RatesDict.Add('40931', 600.0);
//         RatesDict.Add('40932', 600.0);
//         RatesDict.Add('40933', 600.0);
//         RatesDict.Add('40934', 600.0);
//         RatesDict.Add('40935', 600.0);
//         RatesDict.Add('40936', 600.0);
//         RatesDict.Add('40937', 600.0);
//         RatesDict.Add('40938', 600.0);
//         RatesDict.Add('40939', 600.0);
//         RatesDict.Add('40940', 600.0);
//         RatesDict.Add('40941', 600.0);
//         RatesDict.Add('40942', 600.0);
//         RatesDict.Add('40943', 600.0);
//         RatesDict.Add('40944', 600.0);
//         RatesDict.Add('40945', 600.0);
//         RatesDict.Add('40946', 600.0);
//         RatesDict.Add('40950', 600.0);
//         RatesDict.Add('40960', 600.0);
//         RatesDict.Add('40999', 600.0);
//         RatesDict.Add('41000', 600.0);
//         RatesDict.Add('41001', 600.0);
//         RatesDict.Add('41002', 600.0);
//         RatesDict.Add('41003', 600.0);
//         RatesDict.Add('41004', 600.0);
//         RatesDict.Add('41005', 600.0);
//         RatesDict.Add('41006', 600.0);
//         RatesDict.Add('41007', 600.0);
//         RatesDict.Add('41008', 600.0);
//         RatesDict.Add('41009', 600.0);
//         RatesDict.Add('41010', 600.0);
//         RatesDict.Add('41011', 600.0);
//         RatesDict.Add('41012', 600.0);
//         RatesDict.Add('41013', 600.0);
//         RatesDict.Add('41014', 600.0);
//         RatesDict.Add('41015', 600.0);
//         RatesDict.Add('41016', 600.0);
//         RatesDict.Add('41017', 600.0);
//         RatesDict.Add('41018', 600.0);
//         RatesDict.Add('41019', 600.0);
//         RatesDict.Add('41020', 600.0);
//         RatesDict.Add('41021', 600.0);
//         RatesDict.Add('41022', 600.0);
//         RatesDict.Add('41023', 600.0);
//         RatesDict.Add('41024', 600.0);
//         RatesDict.Add('41025', 600.0);
//         RatesDict.Add('41026', 600.0);
//         RatesDict.Add('41027', 600.0);
//         RatesDict.Add('41028', 600.0);
//         RatesDict.Add('41029', 600.0);
//         RatesDict.Add('41030', 600.0);
//         RatesDict.Add('41031', 600.0);
//         RatesDict.Add('41032', 600.0);
//         RatesDict.Add('41099', 600.0);
//         RatesDict.Add('99999', 600.0);
//     end;
// }


report 50209 "Update ACY Target Accounts"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Update ACY Target Accounts';
    Permissions = tabledata "G/L Entry" = rm;

    dataset
    {
        dataitem(GLEntry; "G/L Entry")
        {
            // Removed zero-filter so all entries in the date range are evaluated

            trigger OnPreDataItem()
            begin
                // Date Filter: Restrict processing strictly between 01/01/2026 and 31/07/2026
                GLEntry.SetRange("Posting Date", 20250901D, 20260731D);
            end;

            trigger OnAfterGetRecord()
            var
                TargetRate: Decimal;
            begin
                // Check if current G/L Account No. exists in the dictionary and has a valid rate
                if RatesDict.Get(GLEntry."G/L Account No.", TargetRate) then
                    if TargetRate <> 0 then begin
                        GLEntry."Additional-Currency Amount" := GLEntry.Amount / TargetRate;
                        GLEntry.Modify(false);
                        UpdatedCount += 1;
                    end;
            end;
        }
    }

    trigger OnPreReport()
    var
        AllowedCompany: Text[30];
    begin
        AllowedCompany := 'CIFEAC_BACKUP_21_08_2026';

        // Hard safety check: Lock execution strictly to target company
        if CompanyName <> AllowedCompany then
            Error('Execution blocked: This report can only be executed in company "%1". Current company: "%2".', AllowedCompany, CompanyName);

        InitializeRates();
    end;

    trigger OnPostReport()
    begin
        Message('Successfully updated %1 G/L entries between 01/01/2026 and 31/07/2026 in company %2.', UpdatedCount, CompanyName);
    end;

    var
        RatesDict: Dictionary of [Code[20], Decimal];
        UpdatedCount: Integer;

    local procedure InitializeRates()
    begin
        Clear(RatesDict);

        // Target 323 G/L Accounts and Exchange Rates from Excel
        RatesDict.Add('10111', 612.067112622864);
        RatesDict.Add('10112', 612.065161964577);
        RatesDict.Add('10113', 612.065161964577);
        RatesDict.Add('10135', 603.796192792345);
        RatesDict.Add('10203', 600.189223710127);
        RatesDict.Add('10204', 626.410713623204);
        RatesDict.Add('10205', 626.410713623204);
        RatesDict.Add('10206', 629.548378681642);
        RatesDict.Add('10207', 629.548211630574);
        RatesDict.Add('10208', 629.548211630572);
        RatesDict.Add('10252', 582.760774453498);
        RatesDict.Add('10253', 582.760774453498);
        RatesDict.Add('10254', 597.566984470771);
        RatesDict.Add('10255', 599.300546917621);
        RatesDict.Add('10281', 583.735636998622);
        RatesDict.Add('10282', 546.243254371926);
        RatesDict.Add('10283', 600.003958778663);
        RatesDict.Add('10302', 585.6848011535142);
        RatesDict.Add('10307', 587.4485220505281);
        RatesDict.Add('10314', 600.0);
        RatesDict.Add('10401', 591.449855880716);
        RatesDict.Add('10402', 600.702540127837);
        RatesDict.Add('10403', 581.969974130132);
        RatesDict.Add('10404', 600.702540127837);
        RatesDict.Add('20004', 602.999999999999);
        RatesDict.Add('20007', 615.373395165085);
        RatesDict.Add('20008', 616.213707119308);
        RatesDict.Add('20011', 615.373395165085);
        RatesDict.Add('20012', 616.213707119308);
        RatesDict.Add('20015', 615.373395165085);
        RatesDict.Add('20016', 616.213707119308);
        RatesDict.Add('20019', 615.373395165085);
        RatesDict.Add('20020', 616.213707119308);
        RatesDict.Add('20023', 615.373395165085);
        RatesDict.Add('20024', 616.213707119308);
        RatesDict.Add('20027', 615.3733951650845);
        RatesDict.Add('20028', 616.2137071193082);
        RatesDict.Add('20201', 615.3733951650845);
        RatesDict.Add('20202', 616.2137071193082);
        RatesDict.Add('20214', 618.1883762448052);
        RatesDict.Add('20321', 600.0);
        RatesDict.Add('20345', 595.541656177499);
        RatesDict.Add('20350', 600.0705510664765);
        RatesDict.Add('20451', 600.0151717869943);
        RatesDict.Add('20481', 599.8421524385374);
        RatesDict.Add('20482', 612.4328622277246);
        RatesDict.Add('20483', 608.2197186945417);
        RatesDict.Add('20484', 42.5458802403957);
        RatesDict.Add('20485', 600.0000000000001);
        RatesDict.Add('20502', 600.0240971992035);
        RatesDict.Add('20503', 600.0240971992035);
        RatesDict.Add('20542', 599.9656890380642);
        RatesDict.Add('20543', 579.3372372375198);
        RatesDict.Add('20544', 579.3372372375198);
        RatesDict.Add('20545', 599.982741449142);
        RatesDict.Add('20546', 584.4875533861663);
        RatesDict.Add('20604', 579.3372372375198);
        RatesDict.Add('20605', 579.3372372375198);
        RatesDict.Add('20606', 579.3372372375198);
        RatesDict.Add('20679', 594.4791263035127);
        RatesDict.Add('20681', 599.6715100000005);
        RatesDict.Add('20682', 599.7999062147722);
        RatesDict.Add('20683', 599.610374645138);
        RatesDict.Add('20684', 599.5845084245254);
        RatesDict.Add('20685', 598.7672736032175);
        RatesDict.Add('20687', 600.0000000000022);
        RatesDict.Add('20689', 599.9999997362111);
        RatesDict.Add('20751', 579.3372372375198);
        RatesDict.Add('20752', 579.3372372375198);
        RatesDict.Add('20753', 579.3372372375198);
        RatesDict.Add('20754', 579.3372372375198);
        RatesDict.Add('20755', 579.3372372375198);
        RatesDict.Add('20756', 579.3372372375198);
        RatesDict.Add('20758', 579.3372372375198);
        RatesDict.Add('20760', 579.3372372375198);
        RatesDict.Add('20802', 581.9684853658225);
        RatesDict.Add('20803', 600.0000000447906);
        RatesDict.Add('20804', 600.3299988410388);
        RatesDict.Add('20805', 600.3299988410388);
        RatesDict.Add('20807', 600.3299988410388);
        RatesDict.Add('20831', 600.0000000185443);
        RatesDict.Add('20834', 600.0000000000022);
        RatesDict.Add('20835', 599.3834560632757);
        RatesDict.Add('20839', 599.9999999956067);
        RatesDict.Add('20840', 602.0869565215513);
        RatesDict.Add('20841', 600.000000001176);
        RatesDict.Add('20843', 600.000000000325);
        RatesDict.Add('20844', 600.0005034181233);
        RatesDict.Add('20845', 600.00000000000376);
        RatesDict.Add('20846', 600.0);
        RatesDict.Add('30003', 600.0);
        RatesDict.Add('30004', 600.0);
        RatesDict.Add('30005', 600.0);
        RatesDict.Add('30006', 600.0);
        RatesDict.Add('30007', 600.0);
        RatesDict.Add('30008', 600.0);
        RatesDict.Add('30009', 600.0);
        RatesDict.Add('30100', 600.0);
        RatesDict.Add('30101', 600.0);
        RatesDict.Add('30102', 600.0);
        RatesDict.Add('30103', 600.0);
        RatesDict.Add('30104', 600.0);
        RatesDict.Add('30105', 600.0);
        RatesDict.Add('30106', 600.0);
        RatesDict.Add('30107', 600.0);
        RatesDict.Add('0', 600.0);
        RatesDict.Add('30199', 600.0);
        RatesDict.Add('30300', 600.0);
        RatesDict.Add('39999', 600.0);
        RatesDict.Add('40000', 600.0);
        RatesDict.Add('40001', 600.0);
        RatesDict.Add('40002', 600.0);
        RatesDict.Add('40003', 600.0);
        RatesDict.Add('40004', 600.0);
        RatesDict.Add('40005', 600.0);
        RatesDict.Add('40006', 600.0);
        RatesDict.Add('40007', 600.0);
        RatesDict.Add('40008', 600.0);
        RatesDict.Add('40009', 600.0);
        RatesDict.Add('40010', 600.0);
        RatesDict.Add('40011', 600.0);
        RatesDict.Add('40012', 600.0);
        RatesDict.Add('40013', 600.0);
        RatesDict.Add('40014', 600.0);
        RatesDict.Add('40015', 600.0);
        RatesDict.Add('40016', 600.0);
        RatesDict.Add('40017', 600.0);
        RatesDict.Add('40018', 600.0);
        RatesDict.Add('40149', 600.0);
        RatesDict.Add('40150', 600.0);
        RatesDict.Add('40151', 600.0);
        RatesDict.Add('40152', 600.0);
        RatesDict.Add('40153', 600.0);
        RatesDict.Add('40154', 600.0);
        RatesDict.Add('40155', 600.0);
        RatesDict.Add('40156', 600.0);
        RatesDict.Add('40157', 600.0);
        RatesDict.Add('40158', 600.0);
        RatesDict.Add('40159', 600.0);
        RatesDict.Add('40160', 600.0);
        RatesDict.Add('40249', 600.0);
        RatesDict.Add('40250', 600.0);
        RatesDict.Add('40251', 600.0);
        RatesDict.Add('40252', 600.0);
        RatesDict.Add('40253', 600.0);
        RatesDict.Add('40254', 600.0);
        RatesDict.Add('40255', 600.0);
        RatesDict.Add('40256', 600.0);
        RatesDict.Add('40257', 600.0);
        RatesDict.Add('40258', 600.0);
        RatesDict.Add('40299', 600.0);
        RatesDict.Add('40300', 600.0);
        RatesDict.Add('40301', 600.0);
        RatesDict.Add('40302', 600.0);
        RatesDict.Add('40303', 600.0);
        RatesDict.Add('40304', 600.0);
        RatesDict.Add('40305', 600.0);
        RatesDict.Add('40306', 600.0);
        RatesDict.Add('40307', 600.0);
        RatesDict.Add('40308', 600.0);
        RatesDict.Add('40309', 600.0);
        RatesDict.Add('40310', 600.0);
        RatesDict.Add('40311', 600.0);
        RatesDict.Add('40312', 600.0);
        RatesDict.Add('40313', 600.0);
        RatesDict.Add('40314', 600.0);
        RatesDict.Add('40351', 600.0);
        RatesDict.Add('40352', 600.0);
        RatesDict.Add('40449', 600.0);
        RatesDict.Add('40450', 600.0);
        RatesDict.Add('40451', 600.0);
        RatesDict.Add('40452', 600.0);
        RatesDict.Add('40453', 600.0);
        RatesDict.Add('40454', 600.0);
        RatesDict.Add('40455', 600.0);
        RatesDict.Add('40456', 600.0);
        RatesDict.Add('40457', 600.0);
        RatesDict.Add('40458', 600.0);
        RatesDict.Add('40459', 600.0);
        RatesDict.Add('40460', 600.0);
        RatesDict.Add('40461', 600.0);
        RatesDict.Add('40462', 600.0);
        RatesDict.Add('40463', 600.0);
        RatesDict.Add('40464', 600.0);
        RatesDict.Add('40465', 600.0);
        RatesDict.Add('40466', 600.0);
        RatesDict.Add('40467', 600.0);
        RatesDict.Add('40468', 600.0);
        RatesDict.Add('40469', 600.0);
        RatesDict.Add('40470', 600.0);
        RatesDict.Add('40471', 600.0);
        RatesDict.Add('40549', 600.0);
        RatesDict.Add('40550', 600.0);
        RatesDict.Add('40551', 600.0);
        RatesDict.Add('40552', 600.0);
        RatesDict.Add('40553', 600.0);
        RatesDict.Add('40554', 600.0);
        RatesDict.Add('40555', 600.0);
        RatesDict.Add('40556', 600.0);
        RatesDict.Add('40557', 600.0);
        RatesDict.Add('40558', 600.0);
        RatesDict.Add('40559', 600.0);
        RatesDict.Add('40560', 600.0);
        RatesDict.Add('40561', 600.0);
        RatesDict.Add('40562', 600.0);
        RatesDict.Add('40563', 600.0);
        RatesDict.Add('40564', 600.0);
        RatesDict.Add('40565', 600.0);
        RatesDict.Add('40566', 600.0);
        RatesDict.Add('40567', 600.0);
        RatesDict.Add('40589', 600.0);
        RatesDict.Add('40590', 600.0);
        RatesDict.Add('40591', 600.0);
        RatesDict.Add('40592', 600.0);
        RatesDict.Add('40593', 600.0);
        RatesDict.Add('40594', 600.0);
        RatesDict.Add('40595', 600.0);
        RatesDict.Add('40596', 600.0);
        RatesDict.Add('40597', 600.0);
        RatesDict.Add('40598', 600.0);
        RatesDict.Add('40599', 600.0);
        RatesDict.Add('40849', 600.0);
        RatesDict.Add('40850', 600.0);
        RatesDict.Add('40851', 600.0);
        RatesDict.Add('40852', 600.0);
        RatesDict.Add('40853', 600.0);
        RatesDict.Add('40854', 42.5458802403957);
        RatesDict.Add('40855', 600.0);
        RatesDict.Add('40856', 600.0);
        RatesDict.Add('40857', 600.0);
        RatesDict.Add('40858', 600.0);
        RatesDict.Add('40859', 600.0);
        RatesDict.Add('40860', 600.0);
        RatesDict.Add('40861', 600.0);
        RatesDict.Add('40862', 600.0);
        RatesDict.Add('40863', 600.0);
        RatesDict.Add('40919', 600.0);
        RatesDict.Add('40920', 600.0);
        RatesDict.Add('40921', 600.0);
        RatesDict.Add('40922', 600.0);
        RatesDict.Add('40923', 600.0);
        RatesDict.Add('40924', 600.0);
        RatesDict.Add('40925', 600.0);
        RatesDict.Add('40926', 600.0);
        RatesDict.Add('40927', 600.0);
        RatesDict.Add('40928', 600.0);
        RatesDict.Add('40929', 600.0);
        RatesDict.Add('40930', 600.0);
        RatesDict.Add('40931', 600.0);
        RatesDict.Add('40932', 600.0);
        RatesDict.Add('40933', 600.0);
        RatesDict.Add('40934', 600.0);
        RatesDict.Add('40935', 600.0);
        RatesDict.Add('40936', 600.0);
        RatesDict.Add('40937', 600.0);
        RatesDict.Add('40938', 600.0);
        RatesDict.Add('40939', 600.0);
        RatesDict.Add('40940', 600.0);
        RatesDict.Add('40941', 600.0);
        RatesDict.Add('40942', 600.0);
        RatesDict.Add('40943', 600.0);
        RatesDict.Add('40944', 600.0);
        RatesDict.Add('40945', 600.0);
        RatesDict.Add('40946', 600.0);
        RatesDict.Add('40950', 600.0);
        RatesDict.Add('40960', 600.0);
        RatesDict.Add('40999', 600.0);
        RatesDict.Add('41000', 600.0);
        RatesDict.Add('41001', 600.0);
        RatesDict.Add('41002', 600.0);
        RatesDict.Add('41003', 600.0);
        RatesDict.Add('41004', 600.0);
        RatesDict.Add('41005', 600.0);
        RatesDict.Add('41006', 600.0);
        RatesDict.Add('41007', 600.0);
        RatesDict.Add('41008', 600.0);
        RatesDict.Add('41009', 600.0);
        RatesDict.Add('41010', 600.0);
        RatesDict.Add('41011', 600.0);
        RatesDict.Add('41012', 600.0);
        RatesDict.Add('41013', 600.0);
        RatesDict.Add('41014', 600.0);
        RatesDict.Add('41015', 600.0);
        RatesDict.Add('41016', 600.0);
        RatesDict.Add('41017', 600.0);
        RatesDict.Add('41018', 600.0);
        RatesDict.Add('41019', 600.0);
        RatesDict.Add('41020', 600.0);
        RatesDict.Add('41021', 600.0);
        RatesDict.Add('41022', 600.0);
        RatesDict.Add('41023', 600.0);
        RatesDict.Add('41024', 600.0);
        RatesDict.Add('41025', 600.0);
        RatesDict.Add('41026', 600.0);
        RatesDict.Add('41027', 600.0);
        RatesDict.Add('41028', 600.0);
        RatesDict.Add('41029', 600.0);
        RatesDict.Add('41030', 600.0);
        RatesDict.Add('41031', 600.0);
        RatesDict.Add('41032', 600.0);
        RatesDict.Add('41099', 600.0);
        RatesDict.Add('99999', 600.0);
    end;
}