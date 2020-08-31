IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[nomination_group]') 
					AND name = N'UX_nomination_group_effective_date')
 
BEGIN	
	TRUNCATE TABLE nomination_group
	ALTER TABLE nomination_group
	ADD CONSTRAINT UX_nomination_group_effective_date UNIQUE (nomination_group, effective_date)
END
GO

