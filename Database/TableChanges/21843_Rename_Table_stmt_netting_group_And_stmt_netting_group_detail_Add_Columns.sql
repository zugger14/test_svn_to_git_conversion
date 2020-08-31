IF OBJECT_ID(N'[dbo].[settlement_netting_group]', N'U') IS  NOT NULL
BEGIN
	EXEC sp_rename 'settlement_netting_group', 'stmt_netting_group'
END
GO

IF OBJECT_ID(N'[dbo].[settlement_netting_group_detail]', N'U') IS  NOT NULL
BEGIN
	EXEC sp_rename 'settlement_netting_group_detail', 'stmt_netting_group_detail'
END
GO

IF COL_LENGTH('stmt_netting_group', 'internal_counterparty_id') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD internal_counterparty_id INT
END
GO

IF COL_LENGTH('stmt_netting_group', 'netting_contract_id') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD netting_contract_id INT
END
GO

IF COL_LENGTH('stmt_netting_group', 'effective_date') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD effective_date DATETIME
END
GO

IF COL_LENGTH('stmt_netting_group', 'netting_type') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD netting_type INT
END
GO

IF COL_LENGTH('stmt_netting_group', 'netting_type') IS NOT NULL
BEGIN
    ALTER TABLE stmt_netting_group ALTER COLUMN netting_type INT
END
GO

IF COL_LENGTH('stmt_netting_group', 'create_ts') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD create_ts DATETIME DEFAULT GETDATE()
END
GO

IF COL_LENGTH('stmt_netting_group', 'create_user') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD create_user VARCHAR(100) NULL DEFAULT dbo.FNADBUser()
END
GO

IF COL_LENGTH('stmt_netting_group_detail', 'create_ts') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group_detail ADD create_ts DATETIME DEFAULT GETDATE()
END
GO

IF COL_LENGTH('stmt_netting_group_detail', 'create_user') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group_detail ADD create_user VARCHAR(100) NULL DEFAULT dbo.FNADBUser()
END
GO


IF COL_LENGTH('stmt_netting_group', 'update_ts') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD update_ts DATETIME
END
GO

IF COL_LENGTH('stmt_netting_group', 'update_user') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group ADD update_user VARCHAR(100)
END
GO

IF COL_LENGTH('stmt_netting_group_detail', 'update_ts') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group_detail ADD update_ts DATETIME
END
GO

IF COL_LENGTH('stmt_netting_group_detail', 'update_user') IS NULL
BEGIN
    ALTER TABLE stmt_netting_group_detail ADD update_user VARCHAR(100)
END
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_netting_group]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_netting_group]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_netting_group]
ON [dbo].[stmt_netting_group]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_netting_group
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_netting_group sc
	       INNER JOIN DELETED u ON  sc.netting_group_id = u.netting_group_id  
END
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_netting_group_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_netting_group_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_netting_group_detail]
ON [dbo].[stmt_netting_group_detail]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_netting_group_detail
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_netting_group_detail sc
	       INNER JOIN DELETED u ON  sc.netting_group_detail_id = u.netting_group_detail_id  
END
GO


IF COL_LENGTH('stmt_netting_group', 'template_id') IS NOT NULL
BEGIN
    ALTER TABLE stmt_netting_group ALTER COLUMN template_id INT NULL
END
GO

IF OBJECT_ID('dbo.[FK_settlement_netting_group_detail_contract_group_detail]') IS NOT NULL 
BEGIN
	ALTER TABLE stmt_netting_group_detail
	DROP CONSTRAINT FK_settlement_netting_group_detail_contract_group_detail;
END