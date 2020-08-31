/*
 * [stmt_invoice_netting] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_invoice_netting]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_invoice_netting]
    (
		stmt_invoice_netting_id			INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_id					INT					NOT NULL,
		netting_contract_id				INT,
		contract_id						INT					NOT NULL,
		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts						DATETIME DEFAULT GETDATE(),		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,		CONSTRAINT [PK_stmt_invoice_netting]	PRIMARY KEY CLUSTERED([stmt_invoice_netting_id] ASC),
		CONSTRAINT [FK_stmt_invoice_netting_stmt_invoice_id] FOREIGN KEY (stmt_invoice_id) REFERENCES dbo.stmt_invoice (stmt_invoice_id) ON DELETE CASCADE
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_invoice_netting EXISTS'
END
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_invoice_netting]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_invoice_netting]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_invoice_netting]
ON [dbo].[stmt_invoice_netting]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_invoice_netting
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_invoice_netting sc
	       INNER JOIN DELETED u ON  sc.stmt_invoice_netting_id = u.stmt_invoice_netting_id  
END
