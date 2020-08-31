SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[trm_session]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[trm_session] (
		[trm_session_id]       NVARCHAR(100) PRIMARY KEY NOT NULL,
		[session_updated_time] DATETIME NULL,
		[session_data]         NVARCHAR(MAX) NULL,
		[machine_name]         NVARCHAR(100) NULL,
		[machine_address]      NVARCHAR(100) NULL,
		[create_user]          VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts]            DATETIME NULL DEFAULT GETDATE(),
		[update_user]          VARCHAR(50) NULL,
		[update_ts]            DATETIME NULL
	);
END
ELSE
BEGIN
	PRINT 'Table trm_session EXISTS'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_trm_session]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGUPD_trm_session]
END
GO

CREATE TRIGGER [dbo].[TRGUPD_trm_session] ON [dbo].[trm_session]
FOR UPDATE
AS
	UPDATE trm_session
	  SET
		  [update_user] = [dbo].[FNADBUser](),
		  [update_ts] = GETDATE()
	FROM [trm_session] [t]
	INNER JOIN [DELETED] [u] ON [t].[trm_session_id] = [u].[trm_session_id]
GO