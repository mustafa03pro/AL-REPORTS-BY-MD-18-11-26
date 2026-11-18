enum 50300 "Salesperson Target Period"
{
    Extensible = true;
    Caption = 'Customer Target Period';

    value(0; Weekly)
    {
        Caption = 'Weekly';
    }

    value(1; Monthly)
    {
        Caption = 'Monthly';
    }

    value(2; Quarterly)
    {
        Caption = 'Quarterly';
    }

    value(3; Yearly)
    {
        Caption = 'Yearly';
    }
}