SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_certificate]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].counterparty_certificate(
		counterparty_certificate_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		counterparty_id					INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
		effective_date					DATE NULL,
		expiration_date					DATE NULL,
		certificate_name				VARCHAR(250) NOT NULL,
		comments						VARCHAR(1000) NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].counterparty_certificate EXISTS'
END

GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_counterparty_id_certificate_name_effective_date')
BEGIN
	ALTER TABLE counterparty_certificate
	ADD CONSTRAINT UC_counterparty_id_certificate_name_effective_date UNIQUE (counterparty_id, certificate_name, effective_date)
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_counterparty_certificate]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterparty_certificate]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_certificate]
ON [dbo].[counterparty_certificate]
FOR UPDATE
AS
    UPDATE counterparty_certificate
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM counterparty_certificate t
      INNER JOIN DELETED u ON t.counterparty_certificate_id = u.counterparty_certificate_id
GO