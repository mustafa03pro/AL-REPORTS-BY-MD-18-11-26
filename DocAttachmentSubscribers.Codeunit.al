// codeunit 50210 "DocAttachmentSubscribers"
// {
//     [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
//     local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
//     var
//         FieldRef: FieldRef;
//         RecNo: Code[20];
//     begin
//         case RecRef.Number of
//             Database::"Transfer Header":
//                 begin
//                     FieldRef := RecRef.Field(1); // "No." field
//                     RecNo := FieldRef.Value;
//                     DocumentAttachment.SetRange("Table ID", Database::"Transfer Header");
//                     DocumentAttachment.SetRange("No.", RecNo);
//                 end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
//     local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
//     var
//         FieldRef: FieldRef;
//     begin
//         case RecRef.Number of
//             Database::"Transfer Header":
//                 begin
//                     FieldRef := RecRef.Field(1);
//                     DocumentAttachment."Table ID" := Database::"Transfer Header";
//                     DocumentAttachment."No." := FieldRef.Value;
//                 end;
//         end;
//     end;
// }