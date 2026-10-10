tableextension 50239 "ItemGTINUniquenessExt" extends Item
{
    fields
    {
        modify(GTIN)
        {
            trigger OnBeforeValidate()
            var
                ExistingItem: Record Item;
                DuplicateGTINErr: Label 'The GTIN %1 is already assigned to Item %2 (%3). Duplicate GTINs are not allowed.', Comment = '%1 = GTIN, %2 = Item No., %3 = Description';
            begin
                if Rec.GTIN = '' then
                    exit;

                ExistingItem.Reset();
                ExistingItem.SetCurrentKey(GTIN);
                ExistingItem.SetRange(GTIN, Rec.GTIN);
                ExistingItem.SetFilter("No.", '<>%1', Rec."No.");
                if ExistingItem.FindFirst() then
                    Error(DuplicateGTINErr, Rec.GTIN, ExistingItem."No.", ExistingItem.Description);
            end;
        }
    }
}