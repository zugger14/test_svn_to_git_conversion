IF COL_LENGTH('invoice_email_log', 'create_user') IS NULL
BEGIN
    ALTER TABLE invoice_email_log ADD create_user VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
END
GO

IF COL_LENGTH('invoice_email_log', 'create_ts') IS NULL
BEGIN
    ALTER TABLE invoice_email_log ADD [create_ts] DATETIME NULL DEFAULT GETDATE()
END
GO

IF COL_LENGTH('invoice_email_log', 'update_user') IS NULL
BEGIN
    ALTER TABLE invoice_email_log ADD update_user VARCHAR(50) NULL
END
GO

IF COL_LENGTH('invoice_email_log', 'update_ts') IS NULL
BEGIN
    ALTER TABLE invoice_email_log ADD update_ts DATETIME NULL
END
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_invoice_email_log]'))
    DROP TRIGGER [dbo].[TRGUPD_invoice_email_log]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_invoice_email_log]
ON [dbo].[invoice_email_log]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE invoice_email_log
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM invoice_email_log iel
        INNER JOIN DELETED d ON d.log_id = iel.log_id
    END
END
GO