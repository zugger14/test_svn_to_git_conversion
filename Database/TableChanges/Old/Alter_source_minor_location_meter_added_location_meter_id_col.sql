SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (
       SELECT 1
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[source_minor_location_meter1]')
              AND TYPE IN (N'U')
   )
BEGIN
    CREATE TABLE [dbo].[source_minor_location_meter1]
    (
    	[location_meter_id]         [int] IDENTITY(1, 1) NOT NULL,
    	[meter_id] [int] NOT NULL,
		[meter_name] [varchar](100) NULL,
		[meter_description] [varchar](100) NULL,
		[is_active] [char](1) NULL,
		[source_minor_location_id] [int] NULL,
		[imbalance_applied] [char](1) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
    	CONSTRAINT [PK_source_minor_location_meter1] PRIMARY KEY NONCLUSTERED([location_meter_id] ASC)
    	WITH (
    	    PAD_INDEX = OFF,
    	    STATISTICS_NORECOMPUTE = OFF,
    	    IGNORE_DUP_KEY = OFF,
    	    ALLOW_ROW_LOCKS = ON,
    	    ALLOW_PAGE_LOCKS = ON,
    	    FILLFACTOR = 90
    	) ON [PRIMARY]
    ) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table source_minor_location_meter1 already EXISTS'
END

GO

SET ANSI_PADDING OFF
GO




INSERT INTO source_minor_location_meter1
  (
    meter_id,
    meter_name,
    meter_description,
    is_active,
    source_minor_location_id,
    imbalance_applied
  )
SELECT meter_id,
       meter_name,
       meter_description,
       is_active,
       source_minor_location_id,
       imbalance_applied
FROM   source_minor_location_meter



IF EXISTS (SELECT * FROM sys.objects WHERE object_id IN(OBJECT_ID(N'[dbo].[source_minor_location_meter]'), OBJECT_ID(N'[dbo].[source_minor_location_meter1]'))  AND type in (N'U'))
BEGIN
	DROP TABLE source_minor_location_meter
END


IF EXISTS (
       SELECT 1
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[source_minor_location_meter1]')
              AND TYPE IN (N'U')
   )
BEGIN
	ALTER TABLE dbo.[source_minor_location_meter1] ADD CONSTRAINT
	DF_table_name_create_ts_smlm DEFAULT GETDATE() FOR create_ts
	

	ALTER TABLE dbo.[source_minor_location_meter1] ADD CONSTRAINT
		DF_table_name_create_user_smlm DEFAULT dbo.FNADBUser() FOR create_user

	
	ALTER TABLE [dbo].[source_minor_location_meter1]  WITH NOCHECK ADD  CONSTRAINT 
	[FK_source_minor_location_meter_source_minor_location_meter] FOREIGN KEY([source_minor_location_id])
	REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
	

	ALTER TABLE [dbo].[source_minor_location_meter1] CHECK CONSTRAINT 
	[FK_source_minor_location_meter_source_minor_location_meter]

END

GO


EXECUTE sp_rename N'dbo.source_minor_location_meter1', N'source_minor_location_meter', 'OBJECT'
