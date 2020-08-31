IF OBJECT_ID(N'[dbo].[udt_deal_generator_mapping]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[udt_deal_generator_mapping]
	(	
	[generator_id] INT  NOT NULL,
	[id] INT  PRIMARY KEY  IDENTITY(1, 1)  NOT NULL,
	[source_deal_header_id] INT  NOT NULL,
    [create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts] DATETIME NULL DEFAULT GETDATE(),
    [update_user] VARCHAR(50) NULL,
    [update_ts]	DATETIME NULL
	)
END
ELSE
BEGIN
	PRINT 'Table udt_deal_generator_mapping is already exists.'
END