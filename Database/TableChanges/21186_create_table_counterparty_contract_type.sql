
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_contract_type]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[counterparty_contract_type](
		[counterparty_contract_type_id]			INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[counterparty_contract_address_id]		INT  NULL,
		[counterparty_id]						INT  NULL,
		[contract_id]							INT  NULL,
		[counterparty_contract_type]			INT NOT NULL,
		[application_notes_id]					INT NOT NULL, 
		[create_user]							VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]								DATETIME NULL DEFAULT GETDATE(),
		[update_user]							VARCHAR(50) NULL,
		[update_ts]								DATETIME NULL,
		CONSTRAINT fk_counterparty_contract_type_application_notes_id FOREIGN KEY (application_notes_id)
		REFERENCES application_notes(notes_id)
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [dbo].counterparty_contract_type EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_counterparty_contract_type]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterparty_contract_type]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_contract_type]
ON [dbo].[counterparty_contract_type]
FOR UPDATE
AS
    UPDATE counterparty_contract_type
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM counterparty_contract_type t
      INNER JOIN DELETED u 
		ON t.counterparty_contract_type_id = u.counterparty_contract_type_id
GO