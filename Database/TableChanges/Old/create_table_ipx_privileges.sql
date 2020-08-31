/****** Object:  Table [dbo].[import_export_privileges]    Script Date: 07/09/2013 16:37:33 ******/

IF OBJECT_ID(N'[dbo].[ipx_privileges]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].ipx_privileges
	(
		ipx_privileges_id INT IDENTITY(1,1) NOT NULL,
		[user_id]			NVARCHAR(100) NULL,
		[role_id]			NVARCHAR(100) NULL,
		import_export_id	INT  NULL,
		create_user			NVARCHAR (50) DEFAULT dbo.FNADBUser(),
		create_ts			DATETIME DEFAULT GETDATE(),
		update_user			NVARCHAR (50),
		update_ts			DATETIME  
	)
END
ELSE
	PRINT 'Table ipx_privileges does not exist.' 
	
-----------	 trigger for import_export_privileges----------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ipx_privileges]'))
	DROP TRIGGER [dbo].TRGUPD_ipx_privileges 
GO
CREATE TRIGGER [dbo].TRGUPD_ipx_privileges
ON [dbo].ipx_privileges
FOR UPDATE
AS
BEGIN
	IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ipx_privileges
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ipx_privileges p
		INNER JOIN DELETED d ON p.ipx_privileges_id = d.ipx_privileges_id
	END
END
GO



	


