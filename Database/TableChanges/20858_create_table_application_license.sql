SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_license]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_license] (
		application_license_id  INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		concurrent_user			INT NOT NULL DEFAULT 25,
		database_size			INT NOT NULL DEFAULT 500,
		transaction_count       INT NULL,
		create_user				VARCHAR(64) NULL DEFAULT dbo.FNADBUser(),
		create_ts				DATETIME NULL DEFAULT GETDATE(),
		update_user				VARCHAR(64) NULL,
		update_ts				DATETIME NULL
	)
END
ELSE
BEGIN
	PRINT 'Table application_license EXISTS'
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_application_license]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGUPD_application_license]
END
GO

CREATE TRIGGER [dbo].[TRGUPD_application_license] ON [dbo].[application_license]
FOR UPDATE
AS
	UPDATE application_license
	  SET
		  update_user = dbo.FNADBUser(),
		  update_ts = GETDATE()
	FROM application_license t
	INNER JOIN DELETED u ON t.application_license_id = u.application_license_id
GO