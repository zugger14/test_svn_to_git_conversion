IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_fx_correction_values]'))
    DROP TRIGGER [dbo].TRGUPD_fx_correction_values
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].TRGUPD_fx_correction_values
ON [dbo].fx_correction_values
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE fx_correction_values
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM fx_correction_values an
        INNER JOIN DELETED d ON d.as_of_date = an.as_of_date
    END
END
GO