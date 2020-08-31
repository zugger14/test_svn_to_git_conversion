SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[interface_configuration_detail]', N'U') IS  NULL
BEGIN
	CREATE TABLE interface_configuration_detail (
		id						INT IDENTITY(1,1) PRIMARY KEY,
		interface_id			INT NOT NULL,		--	Refferred to sdv type id 109900
		interface_name			NVARCHAR(255) NOT NULL UNIQUE,
		interface_type			VARCHAR(100) NOT NULL,
		is_active				BIT NOT NULL DEFAULT 1,
		import_rule_hash		VARCHAR(1000) NOT NULL,

		user_login_id			VARCHAR(1000),
		[password]				VARBINARY(max),
		file_store_path			VARCHAR(1000),
		file_log_path			VARCHAR(1000),
		socket_connect_host		VARCHAR(255),
		socket_connect_port		VARCHAR(10),
		sender_comp_id			VARCHAR(1000),
		sender_sub_id			VARCHAR(1000),
		target_comp_id			VARCHAR(1000),

		create_user				VARCHAR(200) DEFAULT dbo.FNADBUser(),
		create_ts				DATETIME DEFAULT GETDATE(),
		update_user				VARCHAR(200),
		update_time				DATETIME 
	)
END
ELSE
BEGIN
    PRINT 'Table interface_configuration_detail EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_interface_configuration_detail]'))
    DROP TRIGGER  [dbo].[TRGUPD_interface_configuration_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_interface_configuration_detail]
ON [dbo].[interface_configuration_detail]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[interface_configuration_detail]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[interface_configuration_detail] icd
        INNER JOIN DELETED d ON d.id = icd.id
    END
END
GO

