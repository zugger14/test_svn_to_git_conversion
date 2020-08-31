SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_schedule]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_schedule]
    (
		[deal_schedule_id]      INT IDENTITY(1, 1) NOT NULL,
		[path_id]				INT,
		[term_start]			DATETIME,
		[term_end]				DATETIME,
		[scheduled_volume]		NUMERIC(38, 20) NULL,
		[delivered_volume]		NUMERIC(38, 20) NULL,
		[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ''deal_schedule'' already EXISTS'
END
 
GO
