SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_application_ui_template_fields]'))
    DROP TRIGGER [dbo].[TRGINS_application_ui_template_fields]
GO

-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_application_ui_template_fields]
ON [dbo].[application_ui_template_fields]
FOR INSERT
AS
BEGIN
	DECLARE @memcache_key			NVARCHAR(MAX)
		, @db					NVARCHAR(200) = db_name()
	SELECT @memcache_key = COALESCE(@memcache_key + ',','') +  CASE WHEN aut.is_report = 'y' 
								THEN  + @db + '_RptStd_' + CAST(aut.application_function_id AS VARCHAR(10))
								ELSE @db + '_UI_' + CAST(aut.application_function_id AS VARCHAR(10))
							END 
	FROM application_ui_template aut
	INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
	INNER JOIN INSERTED autf ON autf.application_ui_field_id = autd.application_ui_field_id
	GROUP BY aut.application_function_id,aut.is_report
	
	IF EXISTS (SELECT 1
		FROM application_ui_template aut
		INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
		INNER JOIN INSERTED autf ON autf.application_ui_field_id = autd.application_ui_field_id
		WHERE aut.is_report = 'y')
	SET @memcache_key = @memcache_key + ',' + @db + '_RptList' 
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'TRGINS_application_ui_template_fields'
	END

END

GO
--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_application_ui_template_fields]'))
    DROP TRIGGER [dbo].[TRGUPD_application_ui_template_fields]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_application_ui_template_fields]
ON [dbo].[application_ui_template_fields]
FOR UPDATE
AS
BEGIN
	 --this check is required to prevent recursive trigger
    IF NOT UPDATE(update_ts)
    BEGIN
        DECLARE @memcache_key			NVARCHAR(MAX)
			, @db					NVARCHAR(200) = db_name()
		SELECT @memcache_key = COALESCE(@memcache_key + ',','') +  CASE WHEN aut.is_report = 'y' 
									THEN  + @db + '_RptStd_' + CAST(aut.application_function_id AS VARCHAR(10))
									ELSE @db + '_UI_' + CAST(aut.application_function_id AS VARCHAR(10))
								END 
		FROM application_ui_template aut
		INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
		INNER JOIN INSERTED autf ON autf.application_ui_field_id = autd.application_ui_field_id
		GROUP BY aut.application_function_id,aut.is_report
	
		IF EXISTS (SELECT 1
			FROM application_ui_template aut
			INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
			INNER JOIN INSERTED autf ON autf.application_ui_field_id = autd.application_ui_field_id
			WHERE aut.is_report = 'y')
		SET @memcache_key = @memcache_key + ',' + @db + '_RptList' 
		 	
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'TRGUPD_application_ui_template_fields'
		END

    END
END

GO
-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_application_ui_template_fields]'))
    DROP TRIGGER [dbo].[TRGDEL_application_ui_template_fields]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_application_ui_template_fields]
ON [dbo].[application_ui_template_fields]
FOR DELETE
AS
BEGIN
DECLARE @memcache_key			NVARCHAR(MAX)
		, @db					NVARCHAR(200) = db_name()
	SELECT @memcache_key = COALESCE(@memcache_key + ',','') +  CASE WHEN aut.is_report = 'y' 
								THEN  + @db + '_RptStd_' + CAST(aut.application_function_id AS VARCHAR(10))
								ELSE @db + '_UI_' + CAST(aut.application_function_id AS VARCHAR(10))
							END 
	FROM application_ui_template aut
	INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
	INNER JOIN DELETED autf ON autf.application_ui_field_id = autd.application_ui_field_id
	GROUP BY aut.application_function_id,aut.is_report
	
	IF EXISTS (SELECT 1
		FROM application_ui_template aut
		INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
		INNER JOIN DELETED autf ON autf.application_ui_field_id = autd.application_ui_field_id
		WHERE aut.is_report = 'y')
	SET @memcache_key = @memcache_key + ',' + @db + '_RptList' 
	
	--select @memcache_key
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'TRGDEL_application_ui_template_fields'
	END
END