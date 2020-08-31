SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
-- Insert trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_excel_sheet]'))
    DROP TRIGGER [dbo].[TRGINS_excel_sheet]
GO
 
CREATE TRIGGER [dbo].[TRGINS_excel_sheet]
ON [dbo].[excel_sheet]
FOR INSERT
AS
BEGIN
	DECLARE @excel_id INT
	SELECT @excel_id = excel_sheet_id FROM deleted 

    --release left grid list.
	DECLARE @key_prefix VARCHAR(50) = DB_NAME() + '_RptList_'
	
	IF  EXISTS (
		SELECT 1 FROM sys.objects 
		WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') 
			AND TYPE IN (N'P', N'PC')
	)
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', 
			@key_prefix = @key_prefix, 
			@cmbobj_key_source = NULL, 
			@other_key_source=NULL,
			@source_object = 'TRGINS_excel_sheet'
	END
END

GO 
-- update trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_excel_sheet]'))
    DROP TRIGGER [dbo].[TRGUPD_excel_sheet]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_excel_sheet]
ON [dbo].[excel_sheet]
FOR UPDATE
AS
BEGIN
	/* IF EXISTS(SELECT 1 FROM INSERTED i 
			INNER JOIN DELETED d ON i.excel_sheet_id = d.excel_sheet_id
	         WHERE CHECKSUM(ISNULL(i.document_type,''),ISNULL(i.[DESCRIPTION],''),ISNULL(i.category_id,''))
				<> CHECKSUM(ISNULL(d.document_type,''),ISNULL(d.[DESCRIPTION],''),ISNULL(d.category_id,''))
			)
	BEGIN */
		DECLARE @excel_id INT
		SELECT @excel_id = excel_sheet_id FROM deleted 
	  
		--release left main grid list and UI keys using '_RptExcel_'.
		DECLARE @key_prefix VARCHAR(2000) = DB_NAME() + '_RptExcel_' + CAST(@excel_id AS VARCHAR)
										+ ',' + DB_NAME() + '_RptList_'
	
		IF  EXISTS (
			SELECT 1 FROM sys.objects 
			WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') 
				AND TYPE IN (N'P', N'PC')
		)
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', 
				@key_prefix = @key_prefix, 
				@cmbobj_key_source = NULL, 
				@other_key_source=NULL,
			@source_object = 'TRGUPD_excel_sheet'
		END
	/* END */
END

GO

-- delete trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_excel_sheet]'))
    DROP TRIGGER [dbo].[TRGDEL_excel_sheet]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_excel_sheet]
ON [dbo].[excel_sheet]
FOR DELETE
AS
BEGIN
	DECLARE @excel_id INT
	SELECT @excel_id = excel_sheet_id FROM deleted 

    --release left main grid list and UI keys using '_RptExcel_'.
	DECLARE @key_prefix VARCHAR(2000) = DB_NAME() + '_RptExcel_' + CAST(@excel_id AS VARCHAR)
									+ ',' + DB_NAME() + '_RptList_'
	
	IF  EXISTS (
		SELECT 1 FROM sys.objects 
		WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') 
			AND TYPE IN (N'P', N'PC')
	)
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', 
			@key_prefix = @key_prefix, 
			@cmbobj_key_source = NULL, 
			@other_key_source=NULL,
			@source_object = 'TRGDEL_excel_sheet'
	END
END