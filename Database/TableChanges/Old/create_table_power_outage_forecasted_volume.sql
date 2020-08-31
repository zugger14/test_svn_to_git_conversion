SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[power_outage_forecasted_volume]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[power_outage_forecasted_volume](
		[power_outage_forecasted_volume_id]	[INT] IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[term_date]					[DATETIME]			NOT NULL,
		[profile_id]				[INT]				NULL,
		[Hr1]						[NUMERIC](38, 20)	NULL,
		[Hr2]						[NUMERIC](38, 20)	NULL,
		[Hr3]						[NUMERIC](38, 20)	NULL,
		[Hr4]						[NUMERIC](38, 20)	NULL,
		[Hr5]						[NUMERIC](38, 20)	NULL,
		[Hr6]						[NUMERIC](38, 20)	NULL,
		[Hr7]						[NUMERIC](38, 20)	NULL,
		[Hr8]						[NUMERIC](38, 20)	NULL,
		[Hr9]						[NUMERIC](38, 20)	NULL,
		[Hr10]						[NUMERIC](38, 20)	NULL,
		[Hr11]						[NUMERIC](38, 20)	NULL,
		[Hr12]						[NUMERIC](38, 20)	NULL,
		[Hr13]						[NUMERIC](38, 20)	NULL,
		[Hr14]						[NUMERIC](38, 20)	NULL,
		[Hr15]						[NUMERIC](38, 20)	NULL,
		[Hr16]						[NUMERIC](38, 20)	NULL,
		[Hr17]						[NUMERIC](38, 20)	NULL,
		[Hr18]						[NUMERIC](38, 20)	NULL,
		[Hr19]						[NUMERIC](38, 20)	NULL,
		[Hr20]						[NUMERIC](38, 20)	NULL,
		[Hr21]						[NUMERIC](38, 20)	NULL,
		[Hr22]						[NUMERIC](38, 20)	NULL,
		[Hr23]						[NUMERIC](38, 20)	NULL,
		[Hr24]						[NUMERIC](38, 20)	NULL,
		[Hr25]						[NUMERIC](38, 20)	NULL,
		[partition_value]			[INT]				NULL,
		[FILE_NAME]					[NVARCHAR](200)		NULL,
		[create_user]               VARCHAR(50) 		NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME 			NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50)			NULL,
    	[update_ts]                 DATETIME 			NULL
	) 
END
ELSE
BEGIN
    PRINT 'Table power_outage_forecasted_volume EXISTS'
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_power_outage_forecasted_volume]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_power_outage_forecasted_volume]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_power_outage_forecasted_volume]
ON [dbo].[power_outage_forecasted_volume]
FOR UPDATE
AS
    UPDATE power_outage_forecasted_volume
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM power_outage_forecasted_volume pofv
      INNER JOIN DELETED u ON pofv.[power_outage_forecasted_volume_id] = u.[power_outage_forecasted_volume_id]
GO