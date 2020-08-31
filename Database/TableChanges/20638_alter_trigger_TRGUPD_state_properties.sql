IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_state_properties]'))
    DROP TRIGGER [dbo].[TRGUPD_state_properties]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_state_properties]
ON [dbo].[state_properties]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE state_properties
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM state_properties an
        INNER JOIN DELETED d ON d.state_value_id = an.state_value_id
    END
END
GO