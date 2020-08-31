
	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	IF OBJECT_ID(N'[dbo].[udt_Gasum_SFTP_Folder_Configuration]', N'U') IS NOT NULL
	BEGIN
		DROP TABLE [dbo].[udt_Gasum_SFTP_Folder_Configuration]
	END
	CREATE TABLE [dbo].[udt_Gasum_SFTP_Folder_Configuration]
		(	
			[id] INT  PRIMARY KEY  IDENTITY(1, 1)  NOT NULL,
			[username] VARCHAR(200) NOT NULL,
			[password] VARCHAR(200) NOT NULL,
			[url] VARCHAR(200) NOT NULL,
			[path] VARCHAR(200) NULL, 
    		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    		[create_ts] DATETIME NULL DEFAULT GETDATE(),
    		[update_user] VARCHAR(50) NULL,
    		[update_ts]	DATETIME NULL
		)
	GO

	IF OBJECT_ID('[dbo].[TRGUPD_udt_Gasum_SFTP_Folder_Configuration]', 'TR') IS NOT NULL
		DROP TRIGGER [dbo].[TRGUPD_udt_Gasum_SFTP_Folder_Configuration]
	GO

	CREATE TRIGGER [dbo].[TRGUPD_udt_Gasum_SFTP_Folder_Configuration]
	ON [dbo].[udt_Gasum_SFTP_Folder_Configuration]
	FOR UPDATE
	AS
		UPDATE udt_Gasum_SFTP_Folder_Configuration
		   SET update_user = dbo.FNADBUser(),
			   update_ts = GETDATE()
		FROM udt_Gasum_SFTP_Folder_Configuration t
		  INNER JOIN DELETED u ON t.[id] = u.[id]
	GO