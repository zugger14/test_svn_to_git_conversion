IF OBJECT_ID('[dbo].[whatif_criteria_migration]') IS NULL
BEGIN
    CREATE TABLE [dbo].whatif_criteria_migration
    (
    	[whatif_criteria_migration_id]     [int] IDENTITY(1, 1) NOT NULL,
    	[maintain_whatif_criteria_id]      INT NOT NULL,
    	[counterparty_id]                  [int] NULL,
    	[risk_rating]                      [int] NULL,
    	[migration]                        [int] NULL,
    	CONSTRAINT PK_whatif_criteria_migration PRIMARY KEY NONCLUSTERED(whatif_criteria_migration_id),
    	CONSTRAINT FK_whatif_criteria_migration_maintain_whatif_criteria FOREIGN 
    	KEY(maintain_whatif_criteria_id) 
    	REFERENCES [dbo].[maintain_whatif_criteria] (criteria_id) 
    	ON DELETE CASCADE 
    	ON UPDATE CASCADE
    )
END
ELSE
    PRINT 'Table whatif_criteria_migration Already Exists'