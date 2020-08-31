SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_schedule_task]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_schedule_task]
    (
		[id]				INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[text]				VARCHAR(500) NULL,
		[start_date]		DATETIME NULL,
		[duration]			INT NULL,
		[progress]			FLOAT NULL,
		[sort_order]		INT NULL,
		[parent]			INT NULL,
		[workflow_id]		INT NULL,
		[workflow_id_type]	INT NULL,
		[create_user]    	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      	DATETIME NULL DEFAULT GETDATE(),
		[update_user]    	VARCHAR(50) NULL,
		[update_ts]      	DATETIME NULL
	)
		
END
ELSE
BEGIN
    PRINT 'Table workflow_schedule_task EXISTS'
END

GO
