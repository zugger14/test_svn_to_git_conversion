SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[power_outage_shaped_volume]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[power_outage_shaped_volume](
		[power_outage_shaped_volume_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[source_deal_detail_id]		INT 			NULL,
		[term_date]					DATETIME 		NULL,
		[hr]						NVARCHAR(5)		NULL,
		[is_dst]					BIT				NULL,
		[volume]					NUMERIC(38, 20)	NULL,
		[price]						FLOAT 			NULL,
		[formula_id]				INT 			NULL,
		[granularity]				INT 			NULL,
		[create_user]               VARCHAR(50) 	NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME 		NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) 	NULL,
    	[update_ts]                 DATETIME 		NULL
	) 
END
ELSE
BEGIN
    PRINT 'Table power_outage_shaped_volume EXISTS'
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_power_outage_shaped_volume]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_power_outage_shaped_volume]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_power_outage_shaped_volume]
ON [dbo].[power_outage_shaped_volume]
FOR UPDATE
AS
    UPDATE power_outage_shaped_volume
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM power_outage_shaped_volume posv
      INNER JOIN DELETED u ON posv.[power_outage_shaped_volume_id] = u.[power_outage_shaped_volume_id]
GO