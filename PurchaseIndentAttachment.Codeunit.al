
codeunit 50258 "Purchase Indent Attachment"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Document Attachment Mgmt",
        'OnAfterGetRefTable',
        '',
        false,
        false)]
    local procedure OnAfterGetRefTable(
        var RecRef: RecordRef;
        DocumentAttachment: Record "Document Attachment")
    var
        IndentHeader: Record "Purchase Indent Header";
    begin
        if DocumentAttachment."Table ID" =
           Database::"Purchase Indent Header"
        then begin
            RecRef.Open(Database::"Purchase Indent Header");

            if IndentHeader.Get(DocumentAttachment."No.") then
                RecRef.GetTable(IndentHeader);
        end;
    end;

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Document Attachment Mgmt",
        'OnAfterTableHasNumberFieldPrimaryKey',
        '',
        false,
        false)]
    local procedure OnAfterTableHasNumberFieldPrimaryKey(
        TableNo: Integer;
        var Result: Boolean;
        var FieldNo: Integer)
    begin
        if TableNo = Database::"Purchase Indent Header" then begin
            FieldNo := 1;
            Result := true;
        end;
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Document Attachment",
        'OnAfterInitFieldsFromRecRef',
        '',
        false,
        false)]
    local procedure OnAfterInitFieldsFromRecRef(
        var DocumentAttachment: Record "Document Attachment";
        var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecRef.Number =
           Database::"Purchase Indent Header"
        then begin
            FieldRef := RecRef.Field(1);
            DocumentAttachment.Validate("No.", FieldRef.Value);
        end;
    end;
}
