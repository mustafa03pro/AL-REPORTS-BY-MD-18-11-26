
query 50310 "Salesperson Target Query"
{
    QueryType = API;

    APIPublisher = 'metworld';
    APIGroup = 'salesTargets';
    APIVersion = 'v1.0';

    EntityName = 'salespersonTarget';
    EntitySetName = 'salespersonTargets';

    Caption = 'Salesperson Sales Target API';

    elements
    {
        dataitem(TargetHeader; "Salesperson Sales Target Head")
        {
            column(targetNo; "No.")
            {
            }

            column(salespersonCode; "Salesperson Code")
            {
            }

            column(salespersonName; "Salesperson Name")
            {
            }

            column(description; Description)
            {
            }

            column(periodType; "Period Type")
            {
            }

            column(startDate; "Start Date")
            {
            }

            column(endDate; "End Date")
            {
            }

            column(createdDate; "Created Date")
            {
            }

            column(createdBy; "Created By")
            {
            }

            dataitem(TargetLine; "Salesperson Sales Target Line")
            {
                DataItemLink =
                    "Target No." = TargetHeader."No.";

                SqlJoinType = LeftOuterJoin;

                column(lineNo; "Line No.")
                {
                }

                column(inventoryPostingGroup;
                "Inventory Posting Group")
                {
                }

                column(targetQuantity; "Target Quantity")
                {
                }

                column(targetRevenue; "Target Revenue")
                {
                }

                column(lineCreatedDate; "Created Date")
                {
                }
            }
        }
    }
}
