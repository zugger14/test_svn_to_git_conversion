
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[generator_ownership_allocation]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[generator_ownership_allocation](
		rec_id  INT IDENTITY(1,1) NOT NULL,
		location_id INT REFERENCES dbo.source_minor_location(source_minor_location_id) NOT NULL,
		owner_id int REFERENCES dbo.source_counterparty(source_counterparty_id) NOT NULL,
		owner_per float,
		effective_date datetime,
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser(),
		update_ts DATETIME  null,
		update_user VARCHAR(50) null
	)

END
ELSE PRINT 'Table ''generator_ownership_allocation'' already exists.'
