IF OBJECT_ID(N'gen_hedge_group', N'U') IS NOT NULL AND COL_LENGTH('gen_hedge_group', 'gen_hedge_group_name') IS NOT NULL
BEGIN
	IF EXISTS(SELECT 1 
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME 
                AND tc.Constraint_name = ccu.Constraint_name     
                AND tc.CONSTRAINT_TYPE = 'UNIQUE' 
                AND tc.Table_Name = 'gen_hedge_group'     
                AND ccu.COLUMN_NAME = 'gen_hedge_group_name' 
	) ALTER TABLE 
	/**
	Column: 
		gen_hedge_group_name: drop constraints  

	*/
	gen_hedge_group DROP  CONSTRAINT    UC_GEN_HEDGE_GROUP_NAME

    ALTER TABLE 
	/**
		Column 
		link_description: Changed gen_hedge_group_name length
	*/
	gen_hedge_group ALTER COLUMN gen_hedge_group_name NVARCHAR(700)
END



IF NOT EXISTS(SELECT 1 
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME 
                AND tc.Constraint_name = ccu.Constraint_name     
                AND tc.CONSTRAINT_TYPE = 'UNIQUE' 
                AND tc.Table_Name = 'gen_hedge_group'     
                AND ccu.COLUMN_NAME = 'gen_hedge_group_name' 
) 
ALTER TABLE 
/**
	Column: 
		gen_hedge_group_name: Add constraints again

*/
[dbo].gen_hedge_group WITH NOCHECK ADD CONSTRAINT [UC_GEN_HEDGE_GROUP_NAME] UNIQUE(gen_hedge_group_name) 

GO 
GO
 


