SET ANSI_PADDING OFF
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
AND TABLE_NAME = 'general_assest_info_virtual_storage')
BEGIN
	ALTER TABLE [dbo].general_assest_info_virtual_storage WITH NOCHECK ADD CONSTRAINT
	[PK_general_assest_id] PRIMARY KEY ([general_assest_id])
END


IF COL_LENGTH('virtual_storage_constraint', 'general_assest_id') IS NULL
BEGIN
    ALTER TABLE virtual_storage_constraint ADD [general_assest_id] INT
END
GO


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_general_assest_id]'))
BEGIN
	ALTER TABLE [dbo].[virtual_storage_constraint] WITH NOCHECK ADD CONSTRAINT
	[FK_general_assest_id] FOREIGN KEY ([general_assest_id])
	REFERENCES [dbo].[general_assest_info_virtual_storage] ([general_assest_id])
END
GO







