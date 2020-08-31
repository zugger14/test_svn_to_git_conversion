IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[fix_message_log]') AND [type] IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[fix_message_log] (
		[fix_message_log_id] INT IDENTITY(1, 1) CONSTRAINT [pk_fix_message_log_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[message_log] NVARCHAR(MAX),
		[fix_type] NVARCHAR(100),
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
	)
END
