IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[contract_group]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].contract_group (
		[contract_name],
		[contract_desc],
		[name],
		[company],
		[address],
		[address2]
	) KEY INDEX PK_contract_group;
	PRINT 'FULLTEXT INDEX ON contract_group created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON contract_group Already Exists.'
GO