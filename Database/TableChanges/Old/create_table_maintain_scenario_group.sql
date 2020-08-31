SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_scenario_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_scenario_group]
    (
    [scenario_group_id]					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [scenario_group_name]				VARCHAR(100) NULL,
    [scenario_group_description]		VARCHAR(100) NULL,
    [user]								VARCHAR(100) NULL,
    [role]								VARCHAR(100) NULL,
    [active]							CHAR(1) NULL,
    [public]							CHAR(1) NULL,
    [source]							VARCHAR(100) NULL,
    [create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]							DATETIME NULL DEFAULT GETDATE(),
    [update_user]						VARCHAR(50) NULL,
    [update_ts]							DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_scenario_group EXISTS'
END

GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_maintain_scenario_group]'))
    DROP TRIGGER [dbo].[TRGUPD_maintain_scenario_group]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_scenario_group]
ON [dbo].[maintain_scenario_group]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE maintain_scenario_group
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM maintain_scenario_group msg
        INNER JOIN DELETED d ON d.scenario_group_id = msg.scenario_group_id
    END
END
GO