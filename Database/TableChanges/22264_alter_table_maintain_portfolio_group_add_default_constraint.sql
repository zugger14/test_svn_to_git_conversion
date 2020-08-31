IF NOT EXISTS(SELECT 1
         FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = 'dbo'
         AND TABLE_NAME = 'maintain_portfolio_group'--table name
         AND COLUMN_NAME = ('create_user')--column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE dbo.maintain_portfolio_group
    ADD CONSTRAINT DF_maintain_portfolio_group_create_user DEFAULT [dbo].[FNADBUser]() FOR create_user
END
