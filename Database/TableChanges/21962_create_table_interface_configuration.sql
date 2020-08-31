SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[interface_configuration]', N'U') IS  NULL
BEGIN
	CREATE TABLE interface_configuration (
		id						INT IDENTITY(1,1) PRIMARY KEY,
		interface_id			INT NOT NULL,		--	Refferred to sdv
		configuration_type		VARCHAR(1000) NOT NULL,		-- Enum varchar values 
		variable_name			NVARCHAR(1000) NOT NULL,
		variable_value			NVARCHAR(MAX),
		create_user				VARCHAR(200) DEFAULT dbo.FNADBUser(),
		create_ts				DATETIME DEFAULT GETDATE(),
		update_user				VARCHAR(200),
		update_time				DATETIME 
	)
END
ELSE
BEGIN
    PRINT 'Table interface_configuration EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_interface_configuration]'))
    DROP TRIGGER  [dbo].[TRGUPD_interface_configuration]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_interface_configuration]
ON [dbo].[interface_configuration]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[interface_configuration]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[interface_configuration] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO

