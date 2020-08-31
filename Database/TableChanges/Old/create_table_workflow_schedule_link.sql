SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_schedule_link]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_schedule_link]
    (
		[id]				INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[source]			INT NULL,
		[target]			INT NULL,
		[type]				INT NULL,
		[action_type]		INT NULL,
		[create_user]    	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      	DATETIME NULL DEFAULT GETDATE(),
		[update_user]    	VARCHAR(50) NULL,
		[update_ts]      	DATETIME NULL
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table workflow_schedule_link EXISTS'
END

GO