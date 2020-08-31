IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPS_GIS_CERTIFICATE]'))
    DROP TRIGGER [dbo].[TRGUPS_GIS_CERTIFICATE]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPS_GIS_CERTIFICATE]
ON [dbo].[Gis_Certificate]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE GIS_CERTIFICATE
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM GIS_CERTIFICATE an
        INNER JOIN DELETED d ON d.source_certificate_number = an.source_certificate_number
    END
END
GO


 



